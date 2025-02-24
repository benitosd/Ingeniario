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

ActiveRecord::Schema[7.1].define(version: 2025_02_24_213617) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "families", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "family_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "properties"
    t.index ["family_id"], name: "index_groups_on_family_id"
  end

  create_table "input_report_stocks", force: :cascade do |t|
    t.bigint "input_report_id", null: false
    t.bigint "stock_id", null: false
    t.bigint "section_id", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "original_status"
    t.index ["input_report_id"], name: "index_input_report_stocks_on_input_report_id"
    t.index ["section_id"], name: "index_input_report_stocks_on_section_id"
    t.index ["stock_id"], name: "index_input_report_stocks_on_stock_id"
  end

  create_table "input_reports", force: :cascade do |t|
    t.bigint "output_report_id", null: false
    t.bigint "user_id", null: false
    t.date "date"
    t.text "notes"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["output_report_id"], name: "index_input_reports_on_output_report_id"
    t.index ["user_id"], name: "index_input_reports_on_user_id"
  end

  create_table "item_locations", force: :cascade do |t|
    t.bigint "section_id"
    t.bigint "user_id"
    t.integer "status"
    t.datetime "assigned_at"
    t.datetime "return_date"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "stock_id", null: false
    t.index ["section_id"], name: "index_item_locations_on_section_id"
    t.index ["stock_id"], name: "index_item_locations_on_stock_id"
    t.index ["user_id"], name: "index_item_locations_on_user_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.json "properties"
    t.bigint "group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_items_on_group_id"
  end

  create_table "output_report_stocks", force: :cascade do |t|
    t.bigint "output_report_id", null: false
    t.bigint "stock_id", null: false
    t.datetime "return_date"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["output_report_id"], name: "index_output_report_stocks_on_output_report_id"
    t.index ["stock_id"], name: "index_output_report_stocks_on_stock_id"
  end

  create_table "output_reports", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "date", null: false
    t.text "reason"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_output_reports_on_user_id"
  end

  create_table "sections", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "warehouse_id", null: false
    t.integer "capacity"
    t.string "location_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["warehouse_id"], name: "index_sections_on_warehouse_id"
  end

  create_table "stock_movements", force: :cascade do |t|
    t.bigint "stock_id", null: false
    t.bigint "user_id", null: false
    t.string "trackable_type", null: false
    t.bigint "trackable_id", null: false
    t.string "action", null: false
    t.string "status", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stock_id"], name: "index_stock_movements_on_stock_id"
    t.index ["trackable_type", "trackable_id"], name: "index_stock_movements_on_trackable"
    t.index ["user_id"], name: "index_stock_movements_on_user_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.string "reference"
    t.text "description"
    t.boolean "active"
    t.datetime "entry_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_stocks_on_item_id"
  end

  create_table "units", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active"
    t.integer "directive"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["code"], name: "index_users_on_code", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "warehouses", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "location"
    t.string "contact_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "groups", "families"
  add_foreign_key "input_report_stocks", "input_reports"
  add_foreign_key "input_report_stocks", "sections"
  add_foreign_key "input_report_stocks", "stocks"
  add_foreign_key "input_reports", "output_reports"
  add_foreign_key "input_reports", "users"
  add_foreign_key "item_locations", "sections"
  add_foreign_key "item_locations", "stocks"
  add_foreign_key "item_locations", "users"
  add_foreign_key "items", "groups"
  add_foreign_key "output_report_stocks", "output_reports"
  add_foreign_key "output_report_stocks", "stocks"
  add_foreign_key "output_reports", "users"
  add_foreign_key "sections", "warehouses"
  add_foreign_key "stock_movements", "stocks"
  add_foreign_key "stock_movements", "users"
  add_foreign_key "stocks", "items"
end
