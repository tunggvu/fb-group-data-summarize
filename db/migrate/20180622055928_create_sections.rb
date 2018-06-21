# frozen_string_literal: true

class CreateSections < ActiveRecord::Migration[5.2]
  def change
    create_table :sections do |t|
      t.references :division, foreign_key: true, null: false, index: true
      t.string :name, null: false

      t.timestamps
    end
  end
end
