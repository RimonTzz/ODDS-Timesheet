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

ActiveRecord::Schema[8.0].define(version: 2025_04_19_113628) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "clients", force: :cascade do |t|
    t.string "client_name"
    t.string "contact_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "holidays", force: :cascade do |t|
    t.date "date", null: false
    t.string "name", null: false
    t.boolean "is_bank_holiday", default: false
    t.boolean "is_exception", default: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_holidays_on_date", unique: true
    t.index ["is_bank_holiday"], name: "index_holidays_on_is_bank_holiday"
    t.index ["is_exception"], name: "index_holidays_on_is_exception"
  end

  create_table "projects", force: :cascade do |t|
    t.string "project_name"
    t.bigint "site_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.time "check_in"
    t.time "check_out"
    t.index ["site_id"], name: "index_projects_on_site_id"
  end

  create_table "sites", force: :cascade do |t|
    t.string "site_name"
    t.string "location"
    t.bigint "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_sites_on_client_id"
  end

  create_table "timesheets", force: :cascade do |t|
    t.date "date"
    t.time "check_in"
    t.time "check_out"
    t.text "work_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "work_status", default: 0
    t.bigint "user_project_id"
    t.index ["user_project_id"], name: "index_timesheets_on_user_project_id"
  end

  create_table "user_projects", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "project_id", null: false
    t.datetime "assigned_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.index ["project_id"], name: "index_user_projects_on_project_id"
    t.index ["user_id"], name: "index_user_projects_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 2, null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "projects", "sites"
  add_foreign_key "sites", "clients"
  add_foreign_key "timesheets", "user_projects", on_delete: :cascade
  add_foreign_key "user_projects", "projects", on_delete: :cascade
  add_foreign_key "user_projects", "users"
end
