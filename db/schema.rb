# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_16_151500) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.integer "admin_user_id", null: false
    t.datetime "created_at", null: false
    t.string "event_type", null: false
    t.text "message", null: false
    t.json "metadata", default: {}, null: false
    t.integer "subject_id", null: false
    t.string "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_user_id"], name: "index_activities_on_admin_user_id"
    t.index ["subject_type", "subject_id", "created_at"], name: "index_activities_on_subject_type_and_subject_id_and_created_at"
    t.index ["subject_type", "subject_id"], name: "index_activities_on_subject"
  end

  create_table "admin_security_events", force: :cascade do |t|
    t.integer "actor_admin_user_id"
    t.datetime "created_at", null: false
    t.string "event_type", null: false
    t.string "ip_address_digest"
    t.json "metadata", default: {}, null: false
    t.string "request_id"
    t.integer "target_admin_user_id"
    t.datetime "updated_at", null: false
    t.string "user_agent_family"
    t.index ["actor_admin_user_id"], name: "index_admin_security_events_on_actor_admin_user_id"
    t.index ["event_type", "created_at"], name: "index_admin_security_events_on_event_type_and_created_at"
    t.index ["request_id"], name: "index_admin_security_events_on_request_id"
    t.index ["target_admin_user_id"], name: "index_admin_security_events_on_target_admin_user_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.text "email_signature"
    t.datetime "last_signed_in_at"
    t.datetime "mfa_enabled_at"
    t.integer "mfa_last_used_at"
    t.json "mfa_recovery_code_digests", default: [], null: false
    t.text "mfa_secret_ciphertext"
    t.string "name", default: "Unbekannt", null: false
    t.json "notification_preferences", default: {}, null: false
    t.string "password_digest", null: false
    t.string "phone"
    t.string "role", default: "owner", null: false
    t.integer "session_version", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["role"], name: "index_admin_users_on_role"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "kind", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["kind"], name: "index_categories_on_kind"
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "checklist_template_items", force: :cascade do |t|
    t.integer "checklist_template_id", null: false
    t.datetime "created_at", null: false
    t.text "instructions"
    t.string "link_url"
    t.text "notes"
    t.integer "position", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "video_url"
    t.index ["checklist_template_id", "position"], name: "idx_on_checklist_template_id_position_7bdf561605"
    t.index ["checklist_template_id"], name: "index_checklist_template_items_on_checklist_template_id"
  end

  create_table "checklist_templates", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "resource_type"
    t.string "section", null: false
    t.datetime "updated_at", null: false
    t.index ["resource_type", "section"], name: "index_checklist_templates_on_resource_type_and_section"
  end

  create_table "configuration_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "customer_snapshot_json"
    t.text "price_snapshot_json"
    t.string "public_token", null: false
    t.integer "scene_id"
    t.text "selected_options_json"
    t.integer "solution_id", null: false
    t.integer "solution_variant_id", null: false
    t.string "status", default: "draft", null: false
    t.datetime "submitted_at"
    t.datetime "updated_at", null: false
    t.text "visual_snapshot_json"
    t.index ["public_token"], name: "index_configuration_sessions_on_public_token", unique: true
    t.index ["scene_id"], name: "index_configuration_sessions_on_scene_id"
    t.index ["solution_id"], name: "index_configuration_sessions_on_solution_id"
    t.index ["solution_variant_id"], name: "index_configuration_sessions_on_solution_variant_id"
    t.index ["status"], name: "index_configuration_sessions_on_status"
    t.index ["submitted_at"], name: "index_configuration_sessions_on_submitted_at"
  end

  create_table "contacts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "customer_id", null: false
    t.string "email"
    t.string "name", null: false
    t.string "phone"
    t.boolean "primary", default: false, null: false
    t.string "role"
    t.datetime "updated_at", null: false
    t.index ["customer_id", "name"], name: "index_contacts_on_customer_id_and_name"
    t.index ["customer_id"], name: "index_contacts_on_customer_id"
  end

  create_table "customers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.text "notes"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_customers_on_name", unique: true
  end

  create_table "document_deliveries", force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "deliverable_id", null: false
    t.string "deliverable_type", null: false
    t.datetime "delivered_at"
    t.datetime "failed_at"
    t.string "idempotency_key", null: false
    t.string "last_error_class"
    t.string "last_error_digest"
    t.string "provider_message_id"
    t.datetime "queued_at", null: false
    t.string "recipient", null: false
    t.integer "requested_by_id", null: false
    t.string "status", default: "queued", null: false
    t.datetime "updated_at", null: false
    t.index ["deliverable_type", "deliverable_id"], name: "index_document_deliveries_on_deliverable"
    t.index ["idempotency_key"], name: "index_document_deliveries_on_idempotency_key", unique: true
    t.index ["requested_by_id"], name: "index_document_deliveries_on_requested_by_id"
    t.index ["status", "queued_at"], name: "index_document_deliveries_on_status_and_queued_at"
  end

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date_from"
    t.date "date_to"
    t.text "description"
    t.string "instagram_url"
    t.string "location"
    t.integer "position", default: 0, null: false
    t.boolean "published", default: true, null: false
    t.string "subtitle"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["date_from"], name: "index_events_on_date_from"
    t.index ["position"], name: "index_events_on_position"
    t.index ["published"], name: "index_events_on_published"
  end

  create_table "help_articles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.string "topic", null: false
    t.datetime "updated_at", null: false
    t.index ["topic"], name: "index_help_articles_on_topic", unique: true
  end

  create_table "help_faqs", force: :cascade do |t|
    t.text "answer", null: false
    t.datetime "created_at", null: false
    t.integer "help_article_id", null: false
    t.integer "position", default: 1, null: false
    t.string "question", null: false
    t.datetime "updated_at", null: false
    t.index ["help_article_id"], name: "index_help_faqs_on_help_article_id"
  end

  create_table "help_requests", force: :cascade do |t|
    t.integer "admin_user_id", null: false
    t.datetime "created_at", null: false
    t.integer "help_article_id"
    t.text "message", null: false
    t.string "page_path", null: false
    t.string "status", default: "open", null: false
    t.string "subject", null: false
    t.string "topic", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_user_id"], name: "index_help_requests_on_admin_user_id"
    t.index ["help_article_id"], name: "index_help_requests_on_help_article_id"
    t.index ["status"], name: "index_help_requests_on_status"
  end

  create_table "inquiries", force: :cascade do |t|
    t.datetime "archived_at"
    t.integer "assigned_admin_user_id"
    t.boolean "bring_own_drinks", default: false, null: false
    t.string "closure_reason"
    t.datetime "created_at", null: false
    t.string "delivery_city"
    t.string "delivery_postcode"
    t.string "delivery_street"
    t.string "email", null: false
    t.string "end_time"
    t.date "ends_on"
    t.date "event_date"
    t.string "event_type"
    t.string "first_name", null: false
    t.boolean "glasses_requested", default: false, null: false
    t.integer "guests"
    t.string "last_name", null: false
    t.text "message"
    t.text "next_step"
    t.date "next_step_due_on"
    t.string "phone"
    t.text "pricing_snapshot"
    t.boolean "privacy_accepted", default: false, null: false
    t.datetime "privacy_notice_acknowledged_at"
    t.string "privacy_notice_version", default: "2026-07-16", null: false
    t.integer "rental_days"
    t.string "rental_mode"
    t.text "selected_options"
    t.string "source", null: false
    t.string "start_time"
    t.date "starts_on"
    t.string "status", default: "new", null: false
    t.decimal "total_price", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["archived_at"], name: "index_inquiries_on_archived_at"
    t.index ["assigned_admin_user_id"], name: "index_inquiries_on_assigned_admin_user_id"
    t.index ["created_at"], name: "index_inquiries_on_created_at"
    t.index ["next_step_due_on"], name: "index_inquiries_on_next_step_due_on"
    t.index ["rental_mode"], name: "index_inquiries_on_rental_mode"
    t.index ["source"], name: "index_inquiries_on_source"
    t.index ["starts_on"], name: "index_inquiries_on_starts_on"
    t.index ["status"], name: "index_inquiries_on_status"
  end

  create_table "invoice_line_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.string "discount_reason"
    t.string "discount_type", default: "none", null: false
    t.decimal "discount_value", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "invoice_id", null: false
    t.decimal "net_unit_price", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "position", default: 0, null: false
    t.decimal "quantity", precision: 10, scale: 2, default: "1.0", null: false
    t.decimal "tax_rate", precision: 5, scale: 2, default: "19.0", null: false
    t.string "unit", default: "Stk", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id", "position"], name: "index_invoice_line_items_on_invoice_id_and_position"
    t.index ["invoice_id"], name: "index_invoice_line_items_on_invoice_id"
  end

  create_table "invoice_sequences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "next_value", default: 1, null: false
    t.datetime "updated_at", null: false
    t.integer "year", null: false
    t.index ["year"], name: "index_invoice_sequences_on_year", unique: true
  end

  create_table "invoices", force: :cascade do |t|
    t.datetime "cancelled_at"
    t.integer "correction_of_id"
    t.datetime "created_at", null: false
    t.date "delivery_on"
    t.string "document_sha256"
    t.text "document_snapshot"
    t.date "due_on"
    t.string "e_invoice_sha256"
    t.datetime "finalized_at"
    t.string "global_discount_reason"
    t.string "global_discount_type", default: "none", null: false
    t.decimal "global_discount_value", precision: 10, scale: 2, default: "0.0", null: false
    t.text "internal_note"
    t.string "invoice_number"
    t.string "invoice_type", default: "invoice", null: false
    t.date "issue_date"
    t.integer "offer_id"
    t.integer "order_id", null: false
    t.datetime "paid_at"
    t.text "recipient_address"
    t.string "recipient_email"
    t.string "recipient_name", null: false
    t.datetime "sent_at"
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.index ["correction_of_id"], name: "index_invoices_on_correction_of_id"
    t.index ["invoice_number"], name: "index_invoices_on_invoice_number", unique: true
    t.index ["offer_id"], name: "index_invoices_on_offer_id"
    t.index ["order_id"], name: "index_invoices_on_order_id"
    t.index ["status"], name: "index_invoices_on_status"
  end

  create_table "offer_line_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.decimal "direct_cost_unit", precision: 10, scale: 2
    t.string "discount_reason"
    t.string "discount_type", default: "none", null: false
    t.decimal "discount_value", precision: 10, scale: 2, default: "0.0", null: false
    t.text "internal_note"
    t.decimal "net_unit_price", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "offer_id", null: false
    t.integer "position", default: 0, null: false
    t.string "position_type", default: "free", null: false
    t.integer "product_variant_id"
    t.decimal "quantity", precision: 10, scale: 2, default: "1.0", null: false
    t.integer "resource_id"
    t.integer "supplier_offering_id"
    t.decimal "tax_rate", precision: 5, scale: 2, default: "19.0", null: false
    t.string "unit", default: "Stk", null: false
    t.datetime "updated_at", null: false
    t.index ["offer_id", "position"], name: "index_offer_line_items_on_offer_id_and_position"
    t.index ["offer_id"], name: "index_offer_line_items_on_offer_id"
    t.index ["product_variant_id"], name: "index_offer_line_items_on_product_variant_id"
    t.index ["resource_id"], name: "index_offer_line_items_on_resource_id"
    t.index ["supplier_offering_id"], name: "index_offer_line_items_on_supplier_offering_id"
  end

  create_table "offers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "document_snapshot"
    t.datetime "finalized_at"
    t.string "global_discount_reason"
    t.string "global_discount_type", default: "none", null: false
    t.decimal "global_discount_value", precision: 10, scale: 2, default: "0.0", null: false
    t.text "internal_note"
    t.string "offer_number"
    t.integer "order_id", null: false
    t.text "recipient_address"
    t.string "recipient_email"
    t.string "recipient_name", null: false
    t.datetime "sent_at"
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.date "valid_until", null: false
    t.integer "version", default: 1, null: false
    t.index ["offer_number"], name: "index_offers_on_offer_number", unique: true
    t.index ["order_id", "version"], name: "index_offers_on_order_id_and_version", unique: true
    t.index ["order_id"], name: "index_offers_on_order_id"
    t.index ["status"], name: "index_offers_on_status"
  end

  create_table "operational_probes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "nonce", null: false
    t.datetime "updated_at", null: false
    t.index ["nonce"], name: "index_operational_probes_on_nonce", unique: true
  end

  create_table "order_checklist_items", force: :cascade do |t|
    t.integer "checklist_template_item_id"
    t.boolean "completed", default: false, null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.text "instructions"
    t.string "link_url"
    t.text "notes"
    t.integer "order_checklist_id", null: false
    t.integer "position", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "video_url"
    t.index ["checklist_template_item_id"], name: "index_order_checklist_items_on_checklist_template_item_id"
    t.index ["order_checklist_id", "position"], name: "index_order_checklist_items_on_order_checklist_id_and_position"
    t.index ["order_checklist_id"], name: "index_order_checklist_items_on_order_checklist_id"
  end

  create_table "order_checklists", force: :cascade do |t|
    t.integer "checklist_template_id"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "order_id", null: false
    t.string "section", null: false
    t.string "status", default: "open", null: false
    t.datetime "updated_at", null: false
    t.index ["checklist_template_id"], name: "index_order_checklists_on_checklist_template_id"
    t.index ["order_id", "status"], name: "index_order_checklists_on_order_id_and_status"
    t.index ["order_id"], name: "index_order_checklists_on_order_id"
  end

  create_table "order_product_selections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "order_id", null: false
    t.integer "product_variant_id", null: false
    t.decimal "quantity", precision: 10, scale: 2, default: "1.0", null: false
    t.string "unit", default: "Stk", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id", "product_variant_id"], name: "idx_order_product_selections_unique", unique: true
    t.index ["order_id"], name: "index_order_product_selections_on_order_id"
    t.index ["product_variant_id"], name: "index_order_product_selections_on_product_variant_id"
  end

  create_table "order_template_checklists", force: :cascade do |t|
    t.integer "checklist_template_id", null: false
    t.datetime "created_at", null: false
    t.integer "order_template_id", null: false
    t.datetime "updated_at", null: false
    t.index ["checklist_template_id"], name: "index_order_template_checklists_on_checklist_template_id"
    t.index ["order_template_id", "checklist_template_id"], name: "idx_order_template_checklists_unique", unique: true
    t.index ["order_template_id"], name: "index_order_template_checklists_on_order_template_id"
  end

  create_table "order_template_product_variants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "order_template_id", null: false
    t.integer "product_variant_id", null: false
    t.decimal "quantity", precision: 10, scale: 2, default: "1.0", null: false
    t.string "unit", default: "Stk", null: false
    t.datetime "updated_at", null: false
    t.index ["order_template_id", "product_variant_id"], name: "idx_template_product_variants_unique", unique: true
    t.index ["order_template_id"], name: "index_order_template_product_variants_on_order_template_id"
    t.index ["product_variant_id"], name: "index_order_template_product_variants_on_product_variant_id"
  end

  create_table "order_template_resources", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "order_template_id", null: false
    t.integer "resource_id", null: false
    t.datetime "updated_at", null: false
    t.index ["order_template_id", "resource_id"], name: "idx_on_order_template_id_resource_id_a1a3dd74b8", unique: true
    t.index ["order_template_id"], name: "index_order_template_resources_on_order_template_id"
    t.index ["resource_id"], name: "index_order_template_resources_on_resource_id"
  end

  create_table "order_template_tasks", force: :cascade do |t|
    t.integer "assigned_admin_user_id"
    t.datetime "created_at", null: false
    t.text "details"
    t.integer "order_template_id", null: false
    t.integer "position", default: 0, null: false
    t.integer "relative_offset_days"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_admin_user_id"], name: "index_order_template_tasks_on_assigned_admin_user_id"
    t.index ["order_template_id"], name: "index_order_template_tasks_on_order_template_id"
  end

  create_table "order_templates", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "customer_message"
    t.string "end_time"
    t.date "ends_on"
    t.string "event_location"
    t.string "event_type"
    t.integer "guests"
    t.string "name", null: false
    t.text "next_step"
    t.integer "responsible_admin_user_id"
    t.boolean "skip_offer", default: false, null: false
    t.string "start_time"
    t.date "starts_on"
    t.datetime "updated_at", null: false
    t.index ["responsible_admin_user_id"], name: "index_order_templates_on_responsible_admin_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "archived_at"
    t.integer "contact_id"
    t.datetime "created_at", null: false
    t.string "customer_email"
    t.integer "customer_id"
    t.text "customer_message"
    t.string "customer_name", null: false
    t.string "customer_phone"
    t.string "end_time"
    t.date "ends_on"
    t.date "event_date"
    t.string "event_location", null: false
    t.string "event_type"
    t.integer "guests"
    t.integer "inquiry_id"
    t.text "inquiry_pricing_snapshot"
    t.text "next_step"
    t.date "next_step_due_on"
    t.integer "responsible_admin_user_id", null: false
    t.string "start_time"
    t.date "starts_on"
    t.string "status", default: "preparing", null: false
    t.datetime "updated_at", null: false
    t.index ["archived_at"], name: "index_orders_on_archived_at"
    t.index ["contact_id"], name: "index_orders_on_contact_id"
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["event_date"], name: "index_orders_on_event_date"
    t.index ["inquiry_id"], name: "index_orders_on_inquiry_id", unique: true
    t.index ["next_step_due_on"], name: "index_orders_on_next_step_due_on"
    t.index ["responsible_admin_user_id"], name: "index_orders_on_responsible_admin_user_id"
    t.index ["status"], name: "index_orders_on_status"
  end

  create_table "privacy_erasure_tombstones", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "erased_at", null: false
    t.json "erased_records", default: {}, null: false
    t.integer "performed_by_id", null: false
    t.string "subject_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["erased_at"], name: "index_privacy_erasure_tombstones_on_erased_at"
    t.index ["subject_digest"], name: "index_privacy_erasure_tombstones_on_subject_digest"
  end

  create_table "privacy_legal_holds", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.datetime "expires_at"
    t.text "reason", null: false
    t.datetime "released_at"
    t.integer "released_by_id"
    t.string "subject_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_privacy_legal_holds_on_expires_at"
    t.index ["released_at"], name: "index_privacy_legal_holds_on_released_at"
    t.index ["subject_digest"], name: "index_privacy_legal_holds_on_subject_digest"
  end

  create_table "procurement_plan_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.integer "lead_time_days"
    t.text "notes"
    t.integer "offer_line_item_id"
    t.date "order_by_on"
    t.integer "procurement_plan_id", null: false
    t.decimal "purchase_price", precision: 10, scale: 2
    t.decimal "quantity", precision: 10, scale: 2, null: false
    t.integer "return_period_days"
    t.string "return_policy"
    t.integer "supplier_offering_id"
    t.string "unit", null: false
    t.datetime "updated_at", null: false
    t.index ["offer_line_item_id"], name: "index_procurement_plan_items_on_offer_line_item_id"
    t.index ["order_by_on"], name: "index_procurement_plan_items_on_order_by_on"
    t.index ["procurement_plan_id"], name: "index_procurement_plan_items_on_procurement_plan_id"
    t.index ["supplier_offering_id"], name: "index_procurement_plan_items_on_supplier_offering_id"
  end

  create_table "procurement_plans", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "non_returnable_confirmed_at"
    t.integer "non_returnable_confirmed_by_id"
    t.text "notes"
    t.integer "offer_id"
    t.date "order_by_on"
    t.integer "order_id", null: false
    t.string "status", default: "planned", null: false
    t.datetime "updated_at", null: false
    t.index ["non_returnable_confirmed_by_id"], name: "index_procurement_plans_on_non_returnable_confirmed_by_id"
    t.index ["offer_id"], name: "index_procurement_plans_on_offer_id"
    t.index ["order_id", "status"], name: "index_procurement_plans_on_order_id_and_status"
    t.index ["order_id"], name: "index_procurement_plans_on_order_id"
  end

  create_table "procurement_profiles", force: :cascade do |t|
    t.text "cancellation_notes"
    t.datetime "created_at", null: false
    t.text "delivery_notes"
    t.integer "lead_time_days", default: 0, null: false
    t.string "name", null: false
    t.integer "return_period_days"
    t.string "return_policy", default: "unknown", null: false
    t.boolean "standard", default: false, null: false
    t.integer "supplier_id"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "idx_standard_procurement_profiles_name", unique: true, where: "standard = 1"
    t.index ["supplier_id", "name"], name: "index_procurement_profiles_on_supplier_id_and_name", unique: true
    t.index ["supplier_id"], name: "index_procurement_profiles_on_supplier_id"
  end

  create_table "product_variants", force: :cascade do |t|
    t.string "availability", default: "Instant", null: false
    t.datetime "created_at", null: false
    t.boolean "is_available", default: true, null: false
    t.string "label"
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "product_id", null: false
    t.string "sales_unit", default: "Fass", null: false
    t.decimal "size", precision: 4, scale: 1, null: false
    t.string "sku", null: false
    t.string "unit", default: "l", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "size", "unit"], name: "index_product_variants_on_product_id_and_size_and_unit", unique: true
    t.index ["product_id"], name: "index_product_variants_on_product_id"
    t.index ["sku"], name: "index_product_variants_on_sku", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.decimal "alcohol_content", precision: 3, scale: 1
    t.string "article_number", null: false
    t.string "brand", null: false
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "featured", default: false, null: false
    t.string "featured_note"
    t.integer "featured_position"
    t.boolean "is_alcoholic", default: true, null: false
    t.string "kind", null: false
    t.string "name", null: false
    t.string "subcategory"
    t.datetime "updated_at", null: false
    t.index ["article_number"], name: "index_products_on_article_number", unique: true
    t.index ["brand", "name"], name: "index_products_on_brand_and_name"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["featured", "featured_position"], name: "index_products_on_featured_and_featured_position"
    t.index ["featured"], name: "index_products_on_featured"
    t.index ["kind"], name: "index_products_on_kind"
  end

  create_table "push_notification_deliveries", force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "delivered_at"
    t.datetime "failed_at"
    t.string "kind", null: false
    t.string "last_error_class"
    t.string "last_error_digest"
    t.date "notification_on", null: false
    t.integer "push_subscription_id", null: false
    t.string "status", default: "queued", null: false
    t.integer "task_id", null: false
    t.datetime "updated_at", null: false
    t.index ["push_subscription_id"], name: "index_push_notification_deliveries_on_push_subscription_id"
    t.index ["status", "notification_on"], name: "idx_on_status_notification_on_8c3a25e457"
    t.index ["task_id", "push_subscription_id", "kind", "notification_on"], name: "idx_push_deliveries_idempotency", unique: true
    t.index ["task_id"], name: "index_push_notification_deliveries_on_task_id"
  end

  create_table "push_subscriptions", force: :cascade do |t|
    t.integer "admin_user_id", null: false
    t.text "auth", null: false
    t.datetime "created_at", null: false
    t.text "endpoint", null: false
    t.text "p256dh", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_user_id"], name: "index_push_subscriptions_on_admin_user_id"
    t.index ["endpoint"], name: "index_push_subscriptions_on_endpoint", unique: true
  end

  create_table "reservations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "ends_at", null: false
    t.text "note"
    t.integer "offer_id"
    t.integer "order_id", null: false
    t.integer "resource_id", null: false
    t.datetime "starts_at", null: false
    t.string "status", default: "reserved", null: false
    t.datetime "updated_at", null: false
    t.index ["offer_id"], name: "index_reservations_on_offer_id"
    t.index ["order_id", "starts_at"], name: "index_reservations_on_order_id_and_starts_at"
    t.index ["order_id"], name: "index_reservations_on_order_id"
    t.index ["resource_id", "starts_at", "ends_at"], name: "index_reservations_on_resource_id_and_starts_at_and_ends_at"
    t.index ["resource_id"], name: "index_reservations_on_resource_id"
    t.index ["status"], name: "index_reservations_on_status"
  end

  create_table "resources", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.text "configuration_notes"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.decimal "rental_net_price", precision: 10, scale: 2
    t.string "rental_position_name"
    t.string "rental_unit", default: "Tag", null: false
    t.string "resource_type", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_resources_on_name", unique: true
    t.index ["resource_type"], name: "index_resources_on_resource_type"
  end

  create_table "scenes", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "metadata_json"
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["active", "position"], name: "index_scenes_on_active_and_position"
    t.index ["slug"], name: "index_scenes_on_slug", unique: true
  end

  create_table "solution_variants", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.integer "base_price_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.text "metadata_json"
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.integer "solution_id", null: false
    t.datetime "updated_at", null: false
    t.index ["solution_id", "active", "position"], name: "index_solution_variants_on_solution_id_and_active_and_position"
    t.index ["solution_id", "slug"], name: "index_solution_variants_on_solution_id_and_slug", unique: true
    t.index ["solution_id"], name: "index_solution_variants_on_solution_id"
  end

  create_table "solutions", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["active", "position"], name: "index_solutions_on_active_and_position"
    t.index ["slug"], name: "index_solutions_on_slug", unique: true
  end

  create_table "supplier_offerings", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.integer "lead_time_days_override"
    t.text "notes"
    t.string "package_content_unit", default: "Stk", null: false
    t.decimal "package_quantity", precision: 10, scale: 2, default: "1.0", null: false
    t.string "package_unit", default: "Fass", null: false
    t.integer "procurement_profile_id", null: false
    t.integer "product_variant_id", null: false
    t.integer "return_period_days_override"
    t.string "return_policy_override"
    t.integer "supplier_id", null: false
    t.string "supplier_sku"
    t.datetime "updated_at", null: false
    t.index ["procurement_profile_id"], name: "index_supplier_offerings_on_procurement_profile_id"
    t.index ["product_variant_id"], name: "index_supplier_offerings_on_product_variant_id"
    t.index ["supplier_id", "product_variant_id"], name: "index_supplier_offerings_on_supplier_id_and_product_variant_id", unique: true
    t.index ["supplier_id"], name: "index_supplier_offerings_on_supplier_id"
  end

  create_table "supplier_prices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "gross_purchase_price", precision: 10, scale: 2, null: false
    t.decimal "purchase_price", precision: 10, scale: 2, null: false
    t.integer "supplier_offering_id", null: false
    t.decimal "tax_rate", precision: 5, scale: 2, default: "19.0", null: false
    t.datetime "updated_at", null: false
    t.date "valid_from", null: false
    t.date "valid_until"
    t.index ["supplier_offering_id", "valid_from"], name: "index_supplier_prices_on_supplier_offering_id_and_valid_from", unique: true
    t.index ["supplier_offering_id"], name: "index_supplier_prices_on_supplier_offering_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.boolean "default_supplier", default: false, null: false
    t.string "email"
    t.string "name", null: false
    t.text "notes"
    t.string "phone"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_suppliers_on_name", unique: true
  end

  create_table "system_settings", force: :cascade do |t|
    t.string "bank_name", default: "Finom PAYMENTS B.V."
    t.string "bic", default: "FNOMDEB2XXXX"
    t.text "company_address", default: "Habsburgerstraße 38\n79104 Freiburg"
    t.string "company_name", default: "Ape2tap UG"
    t.datetime "created_at", null: false
    t.string "iban", default: "DE61100180000698968244"
    t.decimal "internal_hourly_cost", precision: 10, scale: 2
    t.integer "payment_terms_days", default: 14, null: false
    t.decimal "standard_tax_rate", precision: 5, scale: 2, default: "19.0", null: false
    t.datetime "updated_at", null: false
    t.string "vat_id", default: "DE369035041"
  end

  create_table "taggings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "tag_id", null: false
    t.integer "taggable_id", null: false
    t.string "taggable_type", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id", "taggable_type", "taggable_id"], name: "index_taggings_on_tag_id_and_taggable_type_and_taggable_id", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "tasks", force: :cascade do |t|
    t.integer "assigned_admin_user_id"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.text "details"
    t.date "due_on"
    t.date "last_push_reminded_on"
    t.integer "order_id", null: false
    t.integer "procurement_plan_id"
    t.string "relative_anchor"
    t.integer "relative_offset_days"
    t.string "status", default: "open", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_admin_user_id"], name: "index_tasks_on_assigned_admin_user_id"
    t.index ["due_on"], name: "index_tasks_on_due_on"
    t.index ["order_id", "status"], name: "index_tasks_on_order_id_and_status"
    t.index ["order_id"], name: "index_tasks_on_order_id"
    t.index ["procurement_plan_id"], name: "index_tasks_on_procurement_plan_id"
  end

  create_table "time_entries", force: :cascade do |t|
    t.integer "admin_user_id"
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.string "entry_type", null: false
    t.decimal "hourly_cost", precision: 10, scale: 2, null: false
    t.integer "minutes", null: false
    t.text "note"
    t.integer "offer_id"
    t.integer "order_id", null: false
    t.date "recorded_on"
    t.datetime "updated_at", null: false
    t.index ["admin_user_id"], name: "index_time_entries_on_admin_user_id"
    t.index ["offer_id", "entry_type"], name: "index_time_entries_on_offer_id_and_entry_type"
    t.index ["offer_id"], name: "index_time_entries_on_offer_id"
    t.index ["order_id", "entry_type"], name: "index_time_entries_on_order_id_and_entry_type"
    t.index ["order_id"], name: "index_time_entries_on_order_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "admin_users"
  add_foreign_key "admin_security_events", "admin_users", column: "actor_admin_user_id"
  add_foreign_key "admin_security_events", "admin_users", column: "target_admin_user_id"
  add_foreign_key "checklist_template_items", "checklist_templates"
  add_foreign_key "configuration_sessions", "scenes"
  add_foreign_key "configuration_sessions", "solution_variants"
  add_foreign_key "configuration_sessions", "solutions"
  add_foreign_key "contacts", "customers"
  add_foreign_key "document_deliveries", "admin_users", column: "requested_by_id"
  add_foreign_key "help_faqs", "help_articles"
  add_foreign_key "help_requests", "admin_users"
  add_foreign_key "help_requests", "help_articles"
  add_foreign_key "inquiries", "admin_users", column: "assigned_admin_user_id"
  add_foreign_key "invoice_line_items", "invoices"
  add_foreign_key "invoices", "invoices", column: "correction_of_id"
  add_foreign_key "invoices", "offers"
  add_foreign_key "invoices", "orders"
  add_foreign_key "offer_line_items", "offers"
  add_foreign_key "offer_line_items", "product_variants"
  add_foreign_key "offer_line_items", "resources"
  add_foreign_key "offer_line_items", "supplier_offerings"
  add_foreign_key "offers", "orders"
  add_foreign_key "order_checklist_items", "checklist_template_items"
  add_foreign_key "order_checklist_items", "order_checklists"
  add_foreign_key "order_checklists", "checklist_templates"
  add_foreign_key "order_checklists", "orders"
  add_foreign_key "order_product_selections", "orders"
  add_foreign_key "order_product_selections", "product_variants"
  add_foreign_key "order_template_checklists", "checklist_templates"
  add_foreign_key "order_template_checklists", "order_templates"
  add_foreign_key "order_template_product_variants", "order_templates"
  add_foreign_key "order_template_product_variants", "product_variants"
  add_foreign_key "order_template_resources", "order_templates"
  add_foreign_key "order_template_resources", "resources"
  add_foreign_key "order_template_tasks", "admin_users", column: "assigned_admin_user_id"
  add_foreign_key "order_template_tasks", "order_templates"
  add_foreign_key "order_templates", "admin_users", column: "responsible_admin_user_id"
  add_foreign_key "orders", "admin_users", column: "responsible_admin_user_id"
  add_foreign_key "orders", "contacts"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "inquiries"
  add_foreign_key "privacy_erasure_tombstones", "admin_users", column: "performed_by_id"
  add_foreign_key "privacy_legal_holds", "admin_users", column: "created_by_id"
  add_foreign_key "privacy_legal_holds", "admin_users", column: "released_by_id"
  add_foreign_key "procurement_plan_items", "offer_line_items"
  add_foreign_key "procurement_plan_items", "procurement_plans"
  add_foreign_key "procurement_plan_items", "supplier_offerings"
  add_foreign_key "procurement_plans", "admin_users", column: "non_returnable_confirmed_by_id"
  add_foreign_key "procurement_plans", "offers"
  add_foreign_key "procurement_plans", "orders"
  add_foreign_key "procurement_profiles", "suppliers"
  add_foreign_key "product_variants", "products"
  add_foreign_key "products", "categories"
  add_foreign_key "push_notification_deliveries", "push_subscriptions"
  add_foreign_key "push_notification_deliveries", "tasks"
  add_foreign_key "push_subscriptions", "admin_users"
  add_foreign_key "reservations", "offers"
  add_foreign_key "reservations", "orders"
  add_foreign_key "reservations", "resources"
  add_foreign_key "solution_variants", "solutions"
  add_foreign_key "supplier_offerings", "procurement_profiles"
  add_foreign_key "supplier_offerings", "product_variants"
  add_foreign_key "supplier_offerings", "suppliers"
  add_foreign_key "supplier_prices", "supplier_offerings"
  add_foreign_key "taggings", "tags"
  add_foreign_key "tasks", "admin_users", column: "assigned_admin_user_id"
  add_foreign_key "tasks", "orders"
  add_foreign_key "tasks", "procurement_plans"
  add_foreign_key "time_entries", "admin_users"
  add_foreign_key "time_entries", "offers"
  add_foreign_key "time_entries", "orders"
end
