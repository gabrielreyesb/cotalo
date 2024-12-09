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

ActiveRecord::Schema[7.1].define(version: 2024_12_09_114129) do
  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.string "contact"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "general_configurations", force: :cascade do |t|
    t.string "description"
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "unit_id"
    t.index ["unit_id"], name: "index_general_configurations_on_unit_id"
  end

  create_table "manufacturing_processes", force: :cascade do |t|
    t.string "description"
    t.decimal "price", null: false
    t.integer "unit_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "specifications"
    t.string "comments"
    t.integer "maximum_length"
    t.integer "maximum_width"
    t.integer "minimum_length"
    t.integer "minimum_width"
    t.index ["unit_id"], name: "index_manufacturing_processes_on_unit_id"
  end

  create_table "materials", force: :cascade do |t|
    t.string "description"
    t.decimal "width"
    t.decimal "length"
    t.string "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "price", precision: 10, scale: 2
    t.integer "unit_id", null: false
    t.index ["unit_id"], name: "index_materials_on_unit_id"
  end

  create_table "quote_processes", force: :cascade do |t|
    t.integer "quote_id", null: false
    t.integer "manufacturing_process_id", null: false
    t.decimal "price", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["manufacturing_process_id"], name: "index_quote_processes_on_manufacturing_process_id"
    t.index ["quote_id"], name: "index_quote_processes_on_quote_id"
  end

  create_table "quote_toolings", force: :cascade do |t|
    t.integer "quote_id", null: false
    t.integer "tooling_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quantity"
    t.index ["quote_id"], name: "index_quote_toolings_on_quote_id"
    t.index ["tooling_id"], name: "index_quote_toolings_on_tooling_id"
  end

  create_table "quotes", force: :cascade do |t|
    t.string "projects_name", null: false
    t.string "customer_name", null: false
    t.string "customer_organization"
    t.string "customer_email"
    t.integer "product_pieces", null: false
    t.decimal "product_width", null: false
    t.decimal "product_length", null: false
    t.integer "material_id"
    t.integer "material_unit_id"
    t.decimal "material_price"
    t.string "manual_material"
    t.decimal "manual_material_width"
    t.decimal "manual_material_length"
    t.integer "products_per_sheet", null: false
    t.integer "sheets_needed", null: false
    t.decimal "material_total_price", null: false
    t.decimal "material_square_meters", null: false
    t.decimal "subtotal", null: false
    t.decimal "waste", null: false
    t.decimal "margin", null: false
    t.decimal "total_price", null: false
    t.decimal "price_per_piece", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "manual_material_price"
    t.decimal "waste_price", null: false
    t.decimal "margin_price", null: false
    t.integer "manual_material_unit_id"
  end

  create_table "toolings", force: :cascade do |t|
    t.string "description"
    t.decimal "price", precision: 10, scale: 2
    t.integer "unit_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "comments"
    t.index ["unit_id"], name: "index_toolings_on_unit_id"
  end

  create_table "unit_of_measurements", force: :cascade do |t|
    t.string "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["description"], name: "index_unit_of_measurements_on_description", unique: true
  end

  create_table "units", force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vendors", force: :cascade do |t|
    t.string "company"
    t.string "contact_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "general_configurations", "units"
  add_foreign_key "manufacturing_processes", "units"
  add_foreign_key "materials", "units"
  add_foreign_key "quote_processes", "manufacturing_processes"
  add_foreign_key "quote_processes", "quotes"
  add_foreign_key "quote_toolings", "quotes"
  add_foreign_key "quote_toolings", "toolings"
  add_foreign_key "quotes", "materials"
  add_foreign_key "quotes", "units", column: "manual_material_unit_id"
  add_foreign_key "quotes", "units", column: "material_unit_id"
  add_foreign_key "toolings", "units"
end
