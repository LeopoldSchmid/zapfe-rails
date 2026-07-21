require "test_helper"

class InvoiceSequenceTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  YEAR = 2099

  setup do
    InvoiceSequence.where(year: YEAR).delete_all
  end

  teardown do
    InvoiceSequence.where(year: YEAR).delete_all
    @legacy_invoice&.destroy!
  end

  test "allocates unique monotonically increasing values under concurrency" do
    gate = Queue.new
    threads = 8.times.map do
      Thread.new do
        gate.pop
        ApplicationRecord.connection_pool.with_connection do
          InvoiceSequence.take_next!(year: YEAR)
        end
      end
    end
    8.times { gate << true }
    values = threads.map(&:value).sort
    assert_equal (1..8).to_a, values
    assert_equal 9, InvoiceSequence.find_by!(year: YEAR).next_value
  end

  test "starts after existing legacy numbers" do
    @legacy_invoice = Invoice.create!(order: orders(:from_inquiry), recipient_name: "Legacy")
    @legacy_invoice.update_column(:invoice_number, "R-#{YEAR}-000041")

    assert_equal 42, InvoiceSequence.take_next!(year: YEAR)
  end
end
