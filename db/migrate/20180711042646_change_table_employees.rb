# frozen_string_literal: true

class ChangeTableEmployees < ActiveRecord::Migration[5.2]
  def change
    change_column :employees, :organization_id, :bigint, null: true
  end
end
