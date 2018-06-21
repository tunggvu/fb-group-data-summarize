# frozen_string_literal: true

class CreateEfforts < ActiveRecord::Migration[5.2]
  def change
    create_table :efforts do |t|
      t.references :sprint, foreign_key: true, null: false, index: true
      t.references :employee_skill, foreign_key: true, null: false, index: true
      t.integer :effort, null: false

      t.timestamps
    end
  end
end
