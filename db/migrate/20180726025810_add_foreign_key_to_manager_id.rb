# frozen_string_literal: true

class AddForeignKeyToManagerId < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :organizations, :employees, column: :manager_id
  end
end
