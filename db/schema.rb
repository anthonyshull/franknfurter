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

ActiveRecord::Schema[8.1].define(version: 2025_11_10_194541) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "conversions", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "source_currency_code", limit: 3, null: false
    t.string "target_currency_code", limit: 3, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "currencies", primary_key: "code", id: { type: :string, limit: 3 }, force: :cascade do |t|
  end

  create_table "exchange_rates", force: :cascade do |t|
    t.date "date", null: false
    t.string "left_currency_code", limit: 3, null: false
    t.decimal "rate", precision: 10, scale: 5, null: false
    t.string "right_currency_code", limit: 3, null: false
    t.index ["left_currency_code", "right_currency_code", "date"], name: "exchange_rates_index"
    t.check_constraint "left_currency_code::text < right_currency_code::text", name: "left_less_than_right"
  end

  add_foreign_key "conversions", "currencies", column: "source_currency_code", primary_key: "code"
  add_foreign_key "conversions", "currencies", column: "target_currency_code", primary_key: "code"
  add_foreign_key "exchange_rates", "currencies", column: "left_currency_code", primary_key: "code"
  add_foreign_key "exchange_rates", "currencies", column: "right_currency_code", primary_key: "code"
end
