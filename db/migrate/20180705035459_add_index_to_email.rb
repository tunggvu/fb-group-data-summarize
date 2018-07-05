# frozen_string_literal: true

class AddIndexToEmail < ActiveRecord::Migration[5.2]
  def change
    add_index :employees, :email, unique: true
  end
end
