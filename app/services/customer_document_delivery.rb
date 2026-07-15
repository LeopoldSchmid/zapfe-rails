class CustomerDocumentDelivery
  DISABLED_MESSAGE = "Der Versand von Angeboten und Rechnungen ist in dieser Staging-Umgebung deaktiviert. Kontaktformular-Mails bleiben aktiv."

  def self.enabled?
    ActiveModel::Type::Boolean.new.cast(
      ENV.fetch("CUSTOMER_DOCUMENT_DELIVERY_ENABLED", "true")
    )
  end
end
