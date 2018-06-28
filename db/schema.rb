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

ActiveRecord::Schema.define(version: 2018_06_27_070908) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "efforts", force: :cascade do |t|
    t.bigint "sprint_id", null: false
    t.bigint "employee_skill_id", null: false
    t.integer "effort", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_skill_id"], name: "index_efforts_on_employee_skill_id"
    t.index ["sprint_id"], name: "index_efforts_on_sprint_id"
  end

  create_table "employee_roles", force: :cascade do |t|
    t.bigint "role_id", null: false
    t.bigint "employee_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_employee_roles_on_employee_id"
    t.index ["role_id"], name: "index_employee_roles_on_role_id"
  end

  create_table "employee_skills", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.bigint "skill_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_employee_skills_on_employee_id"
    t.index ["skill_id"], name: "index_employee_skills_on_skill_id"
  end

  create_table "employees", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "name", null: false
    t.string "employee_code", null: false
    t.string "email", null: false
    t.boolean "is_admin", default: false
    t.datetime "birthday"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_employees_on_organization_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.integer "parent_id"
    t.integer "manager_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "level", null: false
  end

  create_table "phases", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
  end

  create_table "requirements", force: :cascade do |t|
    t.bigint "skill_id", null: false
    t.bigint "phase_id", null: false
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phase_id"], name: "index_requirements_on_phase_id"
    t.index ["skill_id"], name: "index_requirements_on_skill_id"
  end

  create_table "roles", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.integer "role", limit: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_roles_on_employee_id"
  end

  create_table "skills", force: :cascade do |t|
    t.string "name", null: false
    t.integer "level", limit: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sprints", force: :cascade do |t|
    t.bigint "phase_id", null: false
    t.bigint "project_id", null: false
    t.string "name", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phase_id"], name: "index_sprints_on_phase_id"
    t.index ["project_id"], name: "index_sprints_on_project_id"
  end

  add_foreign_key "efforts", "employee_skills"
  add_foreign_key "efforts", "sprints"
  add_foreign_key "employee_roles", "employees"
  add_foreign_key "employee_roles", "roles"
  add_foreign_key "employee_skills", "employees"
  add_foreign_key "employee_skills", "skills"
  add_foreign_key "employees", "organizations"
  add_foreign_key "phases", "projects"
  add_foreign_key "requirements", "phases"
  add_foreign_key "requirements", "skills"
  add_foreign_key "roles", "employees"
  add_foreign_key "sprints", "phases"
  add_foreign_key "sprints", "projects"
end
