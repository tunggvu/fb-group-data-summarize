# frozen_string_literal: true

class CreateSprints < ActiveRecord::Migration[5.2]
  def change
    create_table :sprints do |t|
      t.references :phase, foreign_key: true, null: false, index: true
      t.references :project, foreign_key: true, null: false, index: true
      t.string :name, null: false
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false

      t.timestamps
    end
  end
end
