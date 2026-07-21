require "test_helper"
require "open3"

class Invoices::FinalizeTest < ActiveSupport::TestCase
  setup do
    @admin = admin_users(:one)
    @invoice = Invoice.create!(order: orders(:from_inquiry), recipient_name: "Verein Freiburg", recipient_email: "rechnung@verein.example", recipient_address: "Musterstraße 1\n79100 Freiburg", due_on: Date.current + 14.days, delivery_on: Date.current)
    @invoice.line_items.create!(description: "Miete Zapfe", quantity: 1, unit: "Tag", net_unit_price: 100, tax_rate: 19, discount_type: "none")
  end

  test "numbers, freezes and renders a finalized invoice" do
    Invoices::Finalize.new(invoice: @invoice, admin_user: @admin).call

    @invoice.reload
    assert_equal "finalized", @invoice.status
    assert_match(/R-#{Date.current.year}-\d{6}/, @invoice.invoice_number)
    assert @invoice.document.attached?
    assert @invoice.e_invoice.attached?
    assert_equal Digest::SHA256.hexdigest(@invoice.document.download), @invoice.document_sha256
    assert_equal Digest::SHA256.hexdigest(@invoice.e_invoice.download), @invoice.e_invoice_sha256
    assert Invoices::XrechnungValidator.new(@invoice.e_invoice.download).validate!
    assert_equal "Ape2tap UG", @invoice.document_snapshot_data.dig("issuer", "company_name")
    assert_not @invoice.update(recipient_name: "Geändert")
  end


  test "renders tax bases and amounts separately for 7 and 19 percent" do
    @invoice.line_items.create!(description: "Lebensmittel", quantity: 1, unit: "Stk", net_unit_price: 100, tax_rate: 7, discount_type: "none")

    Invoices::Finalize.new(invoice: @invoice, admin_user: @admin).call

    breakdown = @invoice.document_snapshot_data.fetch("tax_breakdown")
    assert_equal %w[7.0 19.0], breakdown.map { |entry| entry.fetch("rate") }
    assert_equal %w[7.0 19.0], breakdown.map { |entry| entry.fetch("tax_amount") }
    assert_equal "226.0", @invoice.document_snapshot_data.dig("totals", "gross")

    Tempfile.create([ "mixed-tax-invoice", ".pdf" ]) do |file|
      file.binmode
      file.write(@invoice.document.download)
      file.close
      text, error, status = Open3.capture3("pdftotext", file.path, "-")
      assert status.success?, error
      assert_includes text, "USt. 7.0 % auf 100.00"
      assert_includes text, "USt. 19.0 % auf 100.00"
    end
  end

  test "finalization is idempotent" do
    service = Invoices::Finalize.new(invoice: @invoice, admin_user: @admin)
    first = service.call
    number = first.invoice_number

    assert_same first, service.call
    assert_equal number, @invoice.reload.invoice_number
    assert_equal 1, @invoice.activities.where(event_type: "finalized").count
  end

  test "renderer failure rolls invoice and sequence back to draft" do
    failing_renderer = Class.new do
      def initialize(invoice:) = @invoice = invoice
      def render = raise("synthetic PDF failure")
    end

    assert_raises(RuntimeError) do
      Invoices::Finalize.new(invoice: @invoice, admin_user: @admin, pdf_renderer: failing_renderer).call
    end

    @invoice.reload
    assert_equal "draft", @invoice.status
    assert_nil @invoice.invoice_number
    assert_nil @invoice.finalized_at
    assert_not @invoice.document.attached?
    assert_not @invoice.e_invoice.attached?
  end
end
