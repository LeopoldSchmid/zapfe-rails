module Admin::HelpCenterHelper
  HELP_TOPICS = {
    "dashboard" => "Übersicht",
    "inquiries" => "Anfragen",
    "orders" => "Aufträge",
    "offers" => "Angebote",
    "procurement" => "Beschaffung",
    "execution" => "Durchführung",
    "invoices" => "Rechnungen",
    "notes" => "Freie Notizen",
    "customers" => "Kunden",
    "products" => "Getränke & Mietartikel",
    "suppliers" => "Händler & Preise",
    "resources" => "Ressourcen",
    "order_templates" => "Auftragsvorlagen",
    "checklist_templates" => "Checklisten",
    "settings" => "Einstellungen"
  }.freeze

  def contextual_help_topic
    return "procurement" if controller_name == "orders" && action_name == "procurement"
    return "execution" if controller_name == "orders" && action_name == "execution"
    return "notes" if controller_name == "orders" && action_name == "notes"

    {
      "dashboard" => "dashboard",
      "inquiries" => "inquiries",
      "orders" => "orders",
      "offers" => "offers",
      "invoices" => "invoices",
      "customers" => "customers",
      "products" => "products",
      "categories" => "products",
      "suppliers" => "suppliers",
      "supplier_offerings" => "suppliers",
      "procurement_profiles" => "suppliers",
      "resources" => "resources",
      "order_templates" => "order_templates",
      "checklist_templates" => "checklist_templates",
      "system_settings" => "settings"
    }.fetch(controller_name, "dashboard")
  end

  def contextual_help_title
    HELP_TOPICS.fetch(contextual_help_topic)
  end

  def contextual_help_article
    @contextual_help_article ||= HelpArticle.includes(:faqs).find_by(topic: contextual_help_topic)
  end
end
