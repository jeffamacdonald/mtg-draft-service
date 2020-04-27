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

  create_table "cards", force: :cascade do |t|
    t.string "name", null: false
    t.string "cost"
    t.integer "converted_mana_cost"
    t.string "color_identity", null: false
    t.string "type_line", null: false
    t.string "card_text"
    t.string "layout"
    t.integer "power"
    t.integer "toughness"
    t.string "default_image", null: false
    t.string "default_set", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["card_text"], name: "index_cards_on_card_text"
    t.index ["color_identity"], name: "index_cards_on_color_identity"
    t.index ["converted_mana_cost"], name: "index_cards_on_converted_mana_cost"
    t.index ["name"], name: "index_cards_on_name", unique: true
    t.index ["power"], name: "index_cards_on_power"
    t.index ["toughness"], name: "index_cards_on_toughness"
  end

  create_table "cube_cards", force: :cascade do |t|
    t.bigint "cube_id"
    t.bigint "card_id"
    t.integer "count", null: false
    t.string "custom_set"
    t.string "custom_image"
    t.string "custom_color_identity"
    t.boolean "soft_delete"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["card_id"], name: "index_cube_cards_on_card_id"
    t.index ["cube_id"], name: "index_cube_cards_on_cube_id"
    t.index ["soft_delete"], name: "index_cube_cards_on_soft_delete"
  end

  create_table "cubes", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_cubes_on_name"
    t.index ["user_id"], name: "index_cubes_on_user_id"
  end

  create_table "jwt_blacklist", force: :cascade do |t|
    t.string "jti", null: false
    t.index ["jti"], name: "index_jwt_blacklist_on_jti"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "username"
    t.string "phone"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "cube_cards", "cards"
  add_foreign_key "cube_cards", "cubes"
  add_foreign_key "cubes", "users"
end
