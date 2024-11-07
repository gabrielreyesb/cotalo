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

ActiveRecord::Schema[7.1].define(version: 2024_11_04_225105) do
  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.string "contact"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "manufacturing_processes", force: :cascade do |t|
    t.string "description"
    t.decimal "price"
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
    t.decimal "lenght"
    t.string "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "price", precision: 10, scale: 2
    t.integer "unit_id", null: false
    t.index ["unit_id"], name: "index_materials_on_unit_id"
  end

  create_table "papers", force: :cascade do |t|
    t.string "description"
    t.string "size"
    t.decimal "weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "processes", force: :cascade do |t|
    t.string "description"
    t.decimal "price"
    t.integer "unit_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["unit_id"], name: "index_processes_on_unit_id"
  end

  create_table "quote_processes", force: :cascade do |t|
    t.integer "quote_id", null: false
    t.integer "manufacturing_process_id", null: false
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
    t.index ["quote_id"], name: "index_quote_toolings_on_quote_id"
    t.index ["tooling_id"], name: "index_quote_toolings_on_tooling_id"
  end

  create_table "quotes", force: :cascade do |t|
    t.decimal "width"
    t.decimal "length"
    t.integer "pieces"
    t.integer "material_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "manufacturing_process_id"
    t.index ["material_id"], name: "index_quotes_on_material_id"
  end

  create_table "toolings", force: :cascade do |t|
    t.string "description"
    t.decimal "price", precision: 10, scale: 2
    t.integer "unit_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  add_foreign_key "manufacturing_processes", "units"
  add_foreign_key "materials", "units"
  add_foreign_key "processes", "units"
  add_foreign_key "quote_processes", "manufacturing_processes"
  add_foreign_key "quote_processes", "quotes"
  add_foreign_key "quote_toolings", "quotes"
  add_foreign_key "quote_toolings", "toolings"
  add_foreign_key "quotes", "materials"
  add_foreign_key "toolings", "units"
end
