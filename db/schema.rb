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

ActiveRecord::Schema[8.1].define(version: 2026_03_17_120000) do
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

  create_table "admin_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
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

  create_table "inquiries", force: :cascade do |t|
    t.boolean "bring_own_drinks", default: false, null: false
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
    t.string "phone", null: false
    t.text "pricing_snapshot"
    t.boolean "privacy_accepted", default: false, null: false
    t.integer "rental_days"
    t.string "rental_mode"
    t.text "selected_options"
    t.string "source", null: false
    t.string "start_time"
    t.date "starts_on"
    t.decimal "total_price", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_inquiries_on_created_at"
    t.index ["rental_mode"], name: "index_inquiries_on_rental_mode"
    t.index ["source"], name: "index_inquiries_on_source"
    t.index ["starts_on"], name: "index_inquiries_on_starts_on"
  end

  create_table "product_variants", force: :cascade do |t|
    t.string "availability", default: "Instant", null: false
    t.datetime "created_at", null: false
    t.boolean "is_available", default: true, null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "product_id", null: false
    t.decimal "size", precision: 4, scale: 1, null: false
    t.string "sku", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "size"], name: "index_product_variants_on_product_id_and_size", unique: true
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "product_variants", "products"
  add_foreign_key "products", "categories"
end
