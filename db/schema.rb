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

ActiveRecord::Schema.define(version: 2018_06_22_062555) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "divisions", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

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
    t.bigint "team_id", null: false
    t.string "name", null: false
    t.string "employee_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_employees_on_team_id"
  end

  create_table "groups", force: :cascade do |t|
    t.bigint "section_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["section_id"], name: "index_groups_on_section_id"
  end

  create_table "phases", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_phases_on_project_id"
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

  create_table "sections", force: :cascade do |t|
    t.bigint "division_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["division_id"], name: "index_sections_on_division_id"
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

  create_table "teams", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_teams_on_group_id"
  end

  add_foreign_key "efforts", "employee_skills"
  add_foreign_key "efforts", "sprints"
  add_foreign_key "employee_roles", "employees"
  add_foreign_key "employee_roles", "roles"
  add_foreign_key "employee_skills", "employees"
  add_foreign_key "employee_skills", "skills"
  add_foreign_key "employees", "teams"
  add_foreign_key "groups", "sections"
  add_foreign_key "phases", "projects"
  add_foreign_key "requirements", "phases"
  add_foreign_key "requirements", "skills"
  add_foreign_key "roles", "employees"
  add_foreign_key "sections", "divisions"
  add_foreign_key "sprints", "phases"
  add_foreign_key "sprints", "projects"
  add_foreign_key "teams", "groups"
end
