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

ActiveRecord::Schema[8.0].define(version: 2025_07_13_120001) do
  create_table "tag_groups", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tag_groups_on_name", unique: true
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.integer "tag_group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_group_id", "name"], name: "index_tags_on_tag_group_id_and_name", unique: true
    t.index ["tag_group_id"], name: "index_tags_on_tag_group_id"
  end

  add_foreign_key "tags", "tag_groups"
end
