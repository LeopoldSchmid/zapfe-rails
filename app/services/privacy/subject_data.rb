require "digest"

module Privacy
  class SubjectData
    RetentionRequired = Class.new(StandardError)
    LegalHoldActive = Class.new(StandardError)

    attr_reader :email

    def self.digest(email)
      normalized = email.to_s.strip.downcase
      OpenSSL::HMAC.hexdigest("SHA256", Rails.application.key_generator.generate_key("privacy-subject-digest", 32), normalized)
    end

    def initialize(email)
      @email = email.to_s.strip.downcase
      raise ArgumentError, "E-Mail-Adresse fehlt" if @email.blank?
    end

    def export
      {
        generated_at: Time.current.iso8601,
        subject: email,
        inquiries: inquiries.map { |record| export_record(record, attachment_names: record.attachments.map { |item| item.filename.to_s }) },
        contacts: contacts.map { |record| export_record(record) },
        customers: customers.map { |record| export_record(record) },
        orders: orders.map { |record| export_record(record, attachment_names: record.attachments.map { |item| item.filename.to_s }) },
        offers: offers.map { |record| export_record(record) },
        invoices: invoices.map { |record| export_record(record) }
      }
    end

    def erase!(performed_by:)
      raise LegalHoldActive, "Für die betroffene Person besteht ein aktiver Legal Hold." if PrivacyLegalHold.for_email(email).exists?
      raise RetentionRequired, "Rechnungsbezogene Daten dürfen nur nach freigegebener Aufbewahrungsfrist gelöscht werden." if invoices.exists?

      counts = {}
      ApplicationRecord.transaction do
        subject_orders = orders.to_a
        subject_inquiries = inquiries.to_a
        subject_contacts = contacts.to_a
        subject_customers = customers.to_a

        counts["orders"] = destroy_records(subject_orders)
        counts["inquiries"] = destroy_records(subject_inquiries)
        counts["contacts"] = destroy_records(subject_contacts.select { |record| record.orders.reload.empty? })
        counts["customers"] = destroy_records(subject_customers.select { |record| record.orders.reload.empty? })

        PrivacyErasureTombstone.create!(
          subject_digest: self.class.digest(email),
          erased_records: counts,
          erased_at: Time.current,
          performed_by: performed_by
        )
      end
      counts
    end

    private

    def inquiries
      Inquiry.where("LOWER(email) = ?", email)
    end

    def contacts
      Contact.where("LOWER(email) = ?", email)
    end

    def customers
      Customer.where(id: contacts.select(:customer_id))
    end

    def orders
      Order.where("LOWER(customer_email) = ?", email)
        .or(Order.where(inquiry_id: inquiries.select(:id)))
        .or(Order.where(contact_id: contacts.select(:id)))
    end

    def offers
      Offer.where(order_id: orders.select(:id)).or(Offer.where("LOWER(recipient_email) = ?", email))
    end

    def invoices
      Invoice.where(order_id: orders.select(:id))
    end

    def export_record(record, extras = {})
      record.attributes.except("password_digest").merge(extras).compact
    end

    def destroy_records(records)
      records.each(&:destroy!)
      records.size
    end
  end
end
