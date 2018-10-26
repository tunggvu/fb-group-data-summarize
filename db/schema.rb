# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_10_26_042635) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "devices", force: :cascade do |t|
    t.string "name"
    t.string "serial_code"
    t.integer "device_type"
    t.bigint "project_id"
    t.string "os_version"
    t.bigint "pic_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pic_id"], name: "index_devices_on_pic_id"
    t.index ["project_id"], name: "index_devices_on_project_id"
  end

  create_table "efforts", force: :cascade do |t|
    t.bigint "sprint_id", null: false
    t.bigint "employee_level_id", null: false
    t.integer "effort", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_level_id"], name: "index_efforts_on_employee_level_id"
    t.index ["sprint_id"], name: "index_efforts_on_sprint_id"
  end

  create_table "employee_levels", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "level_id"
    t.index ["employee_id"], name: "index_employee_levels_on_employee_id"
    t.index ["level_id"], name: "index_employee_levels_on_level_id"
  end

  create_table "employee_tokens", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.string "token", null: false
    t.datetime "expired_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_employee_tokens_on_employee_id"
  end

  create_table "employees", force: :cascade do |t|
    t.bigint "organization_id"
    t.string "name", null: false
    t.string "employee_code", null: false
    t.string "email", null: false
    t.boolean "is_admin", default: false
    t.datetime "birthday"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "avatar"
    t.integer "chatwork_room_id"
    t.integer "chatwork_status", default: 0
    t.string "chatwork_account_id"
    t.index ["email"], name: "index_employees_on_email", unique: true
    t.index ["organization_id"], name: "index_employees_on_organization_id"
  end

  create_table "levels", force: :cascade do |t|
    t.integer "rank", null: false
    t.string "name", null: false
    t.string "logo"
    t.bigint "skill_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["skill_id"], name: "index_levels_on_skill_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.integer "manager_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "level", null: false
    t.string "ancestry"
    t.string "logo"
    t.index ["ancestry"], name: "index_organizations_on_ancestry"
  end

  create_table "phases", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "starts_on", null: false
    t.date "ends_on", null: false
    t.index ["project_id"], name: "index_phases_on_project_id"
  end

  create_table "project_chat_rooms", force: :cascade do |t|
    t.text "last_message_id", default: ""
    t.text "chat_room_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "product_owner_id"
    t.string "logo"
    t.string "description"
    t.date "starts_on"
    t.index ["product_owner_id"], name: "index_projects_on_product_owner_id"
  end

  create_table "requests", force: :cascade do |t|
    t.integer "status"
    t.bigint "device_id"
    t.bigint "project_id"
    t.bigint "request_pic_id"
    t.bigint "requester_id"
    t.string "confirmation_digest"
    t.datetime "modified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_requests_on_device_id"
    t.index ["project_id"], name: "index_requests_on_project_id"
    t.index ["request_pic_id"], name: "index_requests_on_request_pic_id"
    t.index ["requester_id"], name: "index_requests_on_requester_id"
  end

  create_table "requirements", force: :cascade do |t|
    t.bigint "phase_id", null: false
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "level_id"
    t.index ["level_id"], name: "index_requirements_on_level_id"
    t.index ["phase_id"], name: "index_requirements_on_phase_id"
  end

  create_table "skills", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "logo"
  end

  create_table "sprints", force: :cascade do |t|
    t.bigint "phase_id", null: false
    t.bigint "project_id", null: false
    t.string "name", null: false
    t.date "starts_on", null: false
    t.date "ends_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phase_id"], name: "index_sprints_on_phase_id"
    t.index ["project_id"], name: "index_sprints_on_project_id"
  end

  create_table "total_efforts", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.date "start_time"
    t.date "end_time"
    t.integer "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_total_efforts_on_employee_id"
  end

  add_foreign_key "devices", "employees", column: "pic_id"
  add_foreign_key "devices", "projects"
  add_foreign_key "efforts", "employee_levels"
  add_foreign_key "efforts", "sprints"
  add_foreign_key "employee_levels", "employees"
  add_foreign_key "employee_levels", "levels"
  add_foreign_key "employee_tokens", "employees"
  add_foreign_key "employees", "organizations"
  add_foreign_key "levels", "skills"
  add_foreign_key "organizations", "employees", column: "manager_id"
  add_foreign_key "phases", "projects"
  add_foreign_key "requests", "devices"
  add_foreign_key "requests", "employees", column: "request_pic_id"
  add_foreign_key "requests", "employees", column: "requester_id"
  add_foreign_key "requests", "projects"
  add_foreign_key "requirements", "levels"
  add_foreign_key "requirements", "phases"
  add_foreign_key "sprints", "phases"
  add_foreign_key "sprints", "projects"
  add_foreign_key "total_efforts", "employees"
end
