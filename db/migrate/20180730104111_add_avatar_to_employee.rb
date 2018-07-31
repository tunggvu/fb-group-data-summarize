# frozen_string_literal: true

class AddAvatarToEmployee < ActiveRecord::Migration[5.2]
  def change
    add_column :employees, :avatar, :string
  end
end
