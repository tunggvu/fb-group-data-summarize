# frozen_string_literal: true

class CreateDevices < ActiveRecord::Migration[5.2]
  def change
    create_table :devices do |t|
      t.string :name
      t.string :serial_code
      t.integer :device_type
      t.references :project, foreign_key: true
      t.string :os_version
      t.references :pic, index: true, foreign_key: { to_table: :employees }

      t.timestamps
    end
  end
end
