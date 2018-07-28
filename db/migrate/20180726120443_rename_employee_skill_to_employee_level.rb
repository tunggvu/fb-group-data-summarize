# frozen_string_literal: true

class RenameEmployeeSkillToEmployeeLevel < ActiveRecord::Migration[5.2]
  def change
    rename_column :efforts, :employee_skill_id, :employee_level_id
  end
end
