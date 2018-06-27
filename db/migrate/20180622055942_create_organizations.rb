# frozen_string_literal: true

class CreateOrganizations < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.integer :parent_id
      t.integer :manager_id, null: false

      t.timestamps
    end
  end
end
