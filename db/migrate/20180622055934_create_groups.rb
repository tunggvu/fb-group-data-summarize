# frozen_string_literal: true

class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
      t.references :section, foreign_key: true, null: false, index: true
      t.string :name, null: false

      t.timestamps
    end
  end
end
