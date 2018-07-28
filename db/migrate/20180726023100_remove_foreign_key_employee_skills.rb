# frozen_string_literal: true

class RemoveForeignKeyEmployeeSkills < ActiveRecord::Migration[5.2]
  def change
    remove_column :employee_skills, :skill_id
  end
end
