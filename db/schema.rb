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

ActiveRecord::Schema[8.0].define(version: 2025_06_02_181647) do
  create_table "companies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "address"
    t.string "email"
    t.string "phone_number"
    t.string "company_name"
    t.string "property_name"
    t.float "latitude"
    t.float "longitude"
    t.text "comments"
    t.boolean "general_pest"
    t.boolean "termites"
    t.boolean "rodents"
    t.boolean "bedbugs"
    t.boolean "other"
    t.string "expo"
    t.string "ai_description"
    t.string "city"
    t.boolean "raffled"
  end
end
