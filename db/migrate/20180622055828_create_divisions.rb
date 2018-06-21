# frozen_string_literal: true

class CreateDivisions < ActiveRecord::Migration[5.2]
  def change
    create_table :divisions do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
