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

ActiveRecord::Schema[8.1].define(version: 2026_08_18_180000) do
  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_events_on_name", unique: true
  end

  create_table "list_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_adult_content", default: false, null: false
    t.boolean "is_featured", default: false, null: false
    t.integer "list_id", null: false
    t.string "source_url"
    t.string "space_number"
    t.datetime "updated_at", null: false
    t.index ["list_id"], name: "index_list_items_on_list_id"
    t.check_constraint "length(source_url) <= 2048", name: "check_list_items_source_url_length"
    t.check_constraint "length(space_number) <= 30", name: "check_list_items_space_number_length"
  end

  create_table "lists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "event_id", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_lists_on_event_id"
    t.index ["token"], name: "index_lists_on_token", unique: true
  end

  add_foreign_key "list_items", "lists"
  add_foreign_key "lists", "events"
end
