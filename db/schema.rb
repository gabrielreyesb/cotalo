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

ActiveRecord::Schema[7.1].define(version: 2025_02_09_195330) do
  create_table "extras", force: :cascade do |t|
    t.string "description"
    t.decimal "price", precision: 10, scale: 2
    t.integer "unit_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "comments"
    t.integer "user_id", null: false
    t.index ["unit_id"], name: "index_extras_on_unit_id"
    t.index ["user_id"], name: "index_extras_on_user_id"
  end

  create_table "general_configurations", force: :cascade do |t|
    t.string "description"
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "unit_id"
    t.integer "user_id", null: false
    t.index ["unit_id"], name: "index_general_configurations_on_unit_id"
    t.index ["user_id"], name: "index_general_configurations_on_user_id"
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
    t.integer "user_id", null: false
    t.index ["unit_id"], name: "index_manufacturing_processes_on_unit_id"
    t.index ["user_id"], name: "index_manufacturing_processes_on_user_id"
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
    t.integer "user_id", null: false
    t.string "specifications"
    t.string "name"
    t.index ["unit_id"], name: "index_materials_on_unit_id"
    t.index ["user_id"], name: "index_materials_on_user_id"
  end

  create_table "quote_extras", force: :cascade do |t|
    t.integer "quote_id", null: false
    t.integer "extra_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quantity"
    t.decimal "price", precision: 10, scale: 2
    t.text "comments"
    t.index ["extra_id"], name: "index_quote_extras_on_extra_id"
    t.index ["quote_id"], name: "index_quote_extras_on_quote_id"
  end

  create_table "quote_materials", force: :cascade do |t|
    t.integer "quote_id", null: false
    t.integer "material_id"
    t.integer "products_per_sheet"
    t.integer "sheets_needed"
    t.decimal "square_meters"
    t.decimal "total_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_manual", default: false
    t.string "manual_description"
    t.string "manual_unit"
    t.decimal "manual_width", precision: 10, scale: 2
    t.decimal "manual_length", precision: 10, scale: 2
    t.boolean "is_main", default: false, null: false
    t.decimal "price_per_unit", precision: 10, scale: 2
    t.decimal "width", precision: 10, scale: 2
    t.decimal "length", precision: 10, scale: 2
    t.text "comments"
    t.index ["material_id"], name: "index_quote_materials_on_material_id"
    t.index ["quote_id"], name: "index_quote_materials_on_quote_id"
  end

  create_table "quote_processes", force: :cascade do |t|
    t.integer "quote_id", null: false
    t.integer "manufacturing_process_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "price", precision: 10, scale: 2
    t.decimal "unit_price", precision: 10, scale: 2
    t.text "comments"
    t.index ["manufacturing_process_id"], name: "index_quote_processes_on_manufacturing_process_id"
    t.index ["quote_id"], name: "index_quote_processes_on_quote_id"
  end

  create_table "quotes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "customer_name"
    t.string "projects_name"
    t.string "customer_organization"
    t.string "customer_email"
    t.integer "product_quantity"
    t.decimal "product_width"
    t.decimal "product_length"
    t.decimal "subtotal"
    t.decimal "waste_percentage"
    t.decimal "margin_percentage"
    t.decimal "total_quote_value", default: "0.0"
    t.decimal "product_value_per_piece"
    t.decimal "waste_price", default: "0.0"
    t.decimal "margin_price", default: "0.0"
    t.text "comments"
    t.string "product_name"
    t.boolean "include_extras", default: false
    t.decimal "price_per_piece_before_margin", precision: 10, scale: 2
    t.string "internal_measures"
    t.string "customer_phone"
    t.index ["user_id"], name: "index_quotes_on_user_id"
  end

  create_table "unit_equivalences", force: :cascade do |t|
    t.integer "unit_one_id", null: false
    t.integer "unit_two_id", null: false
    t.decimal "conversion_factor", precision: 15, scale: 6, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["unit_one_id", "unit_two_id"], name: "index_unit_equivalences_on_unit_one_id_and_unit_two_id", unique: true
    t.index ["unit_one_id"], name: "index_unit_equivalences_on_unit_one_id"
    t.index ["unit_two_id"], name: "index_unit_equivalences_on_unit_two_id"
    t.index ["user_id"], name: "index_unit_equivalences_on_user_id"
  end

  create_table "units", force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_units_on_user_id"
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

  add_foreign_key "extras", "units"
  add_foreign_key "extras", "users"
  add_foreign_key "general_configurations", "units"
  add_foreign_key "general_configurations", "users"
  add_foreign_key "manufacturing_processes", "units"
  add_foreign_key "manufacturing_processes", "users"
  add_foreign_key "materials", "units"
  add_foreign_key "materials", "users"
  add_foreign_key "quote_extras", "extras"
  add_foreign_key "quote_extras", "quotes"
  add_foreign_key "quote_materials", "materials", on_delete: :nullify
  add_foreign_key "quote_materials", "quotes"
  add_foreign_key "quote_processes", "manufacturing_processes"
  add_foreign_key "quote_processes", "quotes"
  add_foreign_key "quotes", "users"
  add_foreign_key "unit_equivalences", "units", column: "unit_one_id"
  add_foreign_key "unit_equivalences", "units", column: "unit_two_id"
  add_foreign_key "unit_equivalences", "users"
  add_foreign_key "units", "users"
end
