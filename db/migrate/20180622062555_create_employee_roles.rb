# frozen_string_literal: true

class CreateEmployeeRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :employee_roles do |t|
      t.references :role, foreign_key: true, null: false, index: true
      t.references :employee, foreign_key: true, null: false, index: true

      t.timestamps
    end
  end
end
