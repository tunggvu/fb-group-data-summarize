# frozen_string_literal: true

class CreateRequirements < ActiveRecord::Migration[5.2]
  def change
    create_table :requirements do |t|
      t.references :skill, foreign_key: true, null: false, index: true
      t.references :phase, foreign_key: true, null: false, index: true
      t.integer :quantity

      t.timestamps
    end
  end
end
