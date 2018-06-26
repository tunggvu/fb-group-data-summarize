# frozen_string_literal: true

class CreateEmployees < ActiveRecord::Migration[5.2]
  def change
    create_table :employees do |t|
      t.references :team, foreign_key: true, null: false, index: true
      t.string :name, null: false
      t.string :employee_code, null: false

      t.timestamps
    end
  end
end
