# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_04_18_001126) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "card_types", force: :cascade do |t|
    t.bigint "cards_id"
    t.string "type"
    t.string "sub_type"
    t.string "super_type"
    t.index ["cards_id"], name: "index_card_types_on_cards_id"
    t.index ["sub_type"], name: "index_card_types_on_sub_type"
    t.index ["type"], name: "index_card_types_on_type"
  end

  create_table "cards", force: :cascade do |t|
    t.string "name", null: false
    t.string "cost"
    t.integer "converted_mana_cost"
    t.string "card_text"
    t.string "layout"
    t.integer "power"
    t.integer "toughness"
    t.string "default_image", null: false
    t.string "color_identity", null: false
    t.index ["card_text"], name: "index_cards_on_card_text"
    t.index ["color_identity"], name: "index_cards_on_color_identity"
    t.index ["converted_mana_cost"], name: "index_cards_on_converted_mana_cost"
    t.index ["name"], name: "index_cards_on_name", unique: true
    t.index ["power"], name: "index_cards_on_power"
    t.index ["toughness"], name: "index_cards_on_toughness"
  end

  create_table "cube_cards", force: :cascade do |t|
    t.bigint "cubes_id"
    t.bigint "cards_id"
    t.string "set"
    t.string "custom_color_identity"
    t.index ["cards_id"], name: "index_cube_cards_on_cards_id"
    t.index ["cubes_id"], name: "index_cube_cards_on_cubes_id"
  end

  create_table "cubes", force: :cascade do |t|
    t.bigint "users_id"
    t.string "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["users_id"], name: "index_cubes_on_users_id"
  end

  create_table "jwt_blacklist", force: :cascade do |t|
    t.string "jti", null: false
    t.index ["jti"], name: "index_jwt_blacklist_on_jti"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "username"
    t.string "phone"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "card_types", "cards", column: "cards_id"
  add_foreign_key "cube_cards", "cards", column: "cards_id"
  add_foreign_key "cube_cards", "cubes", column: "cubes_id"
  add_foreign_key "cubes", "users", column: "users_id"
end
