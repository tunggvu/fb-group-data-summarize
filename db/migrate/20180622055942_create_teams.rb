# frozen_string_literal: true

class CreateTeams < ActiveRecord::Migration[5.2]
  def change
    create_table :teams do |t|
      t.references :group, foreign_key: true, null: false, index: true
      t.string :name, null: false

      t.timestamps
    end
  end
end
