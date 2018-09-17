# frozen_string_literal: true

class CreateRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :requests do |t|
      t.integer :status
      t.references :device, foreign_key: true, index: true
      t.references :project , foreign_key: true, index: true
      t.references :request_pic, index: true, foreign_key: { to_table: :employees }
      t.references :requester, index: true, foreign_key: { to_table: :employees }
      t.string :confirmation_digest
      t.date :modified_date

      t.timestamps
    end
  end
end
