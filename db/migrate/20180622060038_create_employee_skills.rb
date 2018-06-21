# frozen_string_literal: true

class CreateEmployeeSkills < ActiveRecord::Migration[5.2]
  def change
    create_table :employee_skills do |t|
      t.references :employee, foreign_key: true, null: false, index: true
      t.references :skill, foreign_key: true, null: false, index: true

      t.timestamps
    end
  end
end
