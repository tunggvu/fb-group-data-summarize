# frozen_string_literal: true

class CreateEmployeeTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :employee_tokens do |t|
      t.references :employee,      index: true, null: false, foreign_key: true
      t.string :token,         null: false
      t.datetime :expired_at,  null: false

      t.timestamps
    end
  end
end
