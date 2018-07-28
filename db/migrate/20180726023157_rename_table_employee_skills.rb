# frozen_string_literal: true

class RenameTableEmployeeSkills < ActiveRecord::Migration[5.2]
  def change
    rename_table :employee_skills, :employee_levels
  end
end
