# frozen_string_literal: true

class AddLevelToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :level, :integer, null: false
  end
end
