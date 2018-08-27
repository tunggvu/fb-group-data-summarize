# frozen_string_literal: true

class CreateTotalEfforts < ActiveRecord::Migration[5.2]
  def change
    create_table :total_efforts do |t|
      t.references :employee, foreign_key: true, null: false, index: true
      t.date :start_time
      t.date :end_time
      t.integer :value

      t.timestamps
    end
  end
end
