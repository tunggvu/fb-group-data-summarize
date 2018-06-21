# frozen_string_literal: true

class CreatePhases < ActiveRecord::Migration[5.2]
  def change
    create_table :phases do |t|
      t.references :project, foreign_key: true, null: false, index: true
      t.string :name, null: false

      t.timestamps
    end
  end
end
