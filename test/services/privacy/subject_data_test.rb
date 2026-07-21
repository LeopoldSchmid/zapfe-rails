require "test_helper"

class Privacy::SubjectDataTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @email = "synthetic-rights-subject@example.test"
    @admin = admin_users(:one)
    @inquiry = Inquiry.create!(
      source: "contact",
      first_name: "Synthetic",
      last_name: "Subject",
      email: @email,
      privacy_accepted: true
    )
  end

  test "exports all directly linked subject records and attachment metadata" do
    @inquiry.attachments.attach(io: StringIO.new("%PDF-1.4\n%%EOF\n"), filename: "request.pdf", content_type: "application/pdf")
    order = create_order!
    offer = order.offers.create!(recipient_name: "Synthetic Subject", recipient_email: @email, valid_until: 14.days.from_now.to_date)
    order.invoices.create!(offer: offer, recipient_name: "Synthetic Subject")

    export = Privacy::SubjectData.new(@email.upcase).export

    assert_equal @email, export.fetch(:subject)
    assert_equal [ "request.pdf" ], export.dig(:inquiries, 0, :attachment_names)
    assert_equal 1, export.fetch(:orders).size
    assert_equal 1, export.fetch(:offers).size
    assert_equal 1, export.fetch(:invoices).size
  end

  test "erases a non-invoiced subject graph and leaves only a pseudonymous tombstone" do
    order = create_order!
    digest = Privacy::SubjectData.digest(@email)

    counts = Privacy::SubjectData.new(@email).erase!(performed_by: @admin)

    assert_equal 1, counts.fetch("orders")
    assert_not Inquiry.exists?(@inquiry.id)
    assert_not Order.exists?(order.id)
    tombstone = PrivacyErasureTombstone.find_by!(subject_digest: digest)
    assert_equal counts, tombstone.erased_records
    assert_not_includes tombstone.attributes.to_json, @email
    assert_not tombstone.destroy
  end

  test "fails closed while a legal hold is active" do
    hold = PrivacyLegalHold.create!(
      subject_digest: Privacy::SubjectData.digest(@email),
      reason: "Synthetic dispute",
      created_by: @admin
    )

    assert_raises(Privacy::SubjectData::LegalHoldActive) do
      Privacy::SubjectData.new(@email).erase!(performed_by: @admin)
    end
    assert Inquiry.exists?(@inquiry.id)

    hold.release!(by: @admin)
    assert_predicate hold, :released_at?
  end

  test "fails closed when invoices require retention" do
    order = create_order!
    order.invoices.create!(recipient_name: "Synthetic Subject")

    assert_raises(Privacy::SubjectData::RetentionRequired) do
      Privacy::SubjectData.new(@email).erase!(performed_by: @admin)
    end
    assert Order.exists?(order.id)
    assert_equal 0, PrivacyErasureTombstone.where(subject_digest: Privacy::SubjectData.digest(@email)).count
  end

  private

  def create_order!
    Order.create!(
      inquiry: @inquiry,
      responsible_admin_user: @admin,
      customer_name: "Synthetic Subject",
      customer_email: @email,
      event_location: "Synthetic venue"
    )
  end
end
