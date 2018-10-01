# frozen_string_literal: true

class AddTypeOfRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :requests, :request_type, :integer, null: false, default: 1
  end
end
