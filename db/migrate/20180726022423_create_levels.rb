# frozen_string_literal: true

class CreateLevels < ActiveRecord::Migration[5.2]
  def change
    create_table :levels do |t|
      t.integer :rank, null: false
      t.string :name, null: false
      t.string :logo
      t.references :skill, foreign_key: true, index: true, null: false

      t.timestamps
    end
  end
end
