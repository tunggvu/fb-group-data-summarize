# frozen_string_literal: true

class CreateRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :roles do |t|
      t.references :employee, foreign_key: true, null: false, index: true
      t.integer :role, limit: 1

      t.timestamps
    end
  end
end
