# frozen_string_literal: true

class CreateEmployees < ActiveRecord::Migration[5.2]
  def change
    create_table :employees do |t|
      t.references :organization, foreign_key: true, null: false, index: true
      t.string :name, null: false
      t.string :employee_code, null: false
      t.string :email, null: false
      t.boolean :is_admin, default: false
      t.datetime :birthday
      t.string :phone

      t.timestamps
    end
  end
end
