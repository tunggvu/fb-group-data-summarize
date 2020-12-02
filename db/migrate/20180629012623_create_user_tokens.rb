# frozen_string_literal: true

class CreateUserTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :user_tokens do |t|
      t.references :user, index: true, null: false, foreign_key: true
      t.string :token, null: false
      t.datetime :expired_at, null: false

      t.timestamps
    end
  end
end
