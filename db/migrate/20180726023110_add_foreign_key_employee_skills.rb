# frozen_string_literal: true

class AddForeignKeyEmployeeSkills < ActiveRecord::Migration[5.2]
  def change
    add_reference :employee_skills, :level, foreign_key: true
  end
end
