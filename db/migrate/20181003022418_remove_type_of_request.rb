# frozen_string_literal: true

class RemoveTypeOfRequest < ActiveRecord::Migration[5.2]
  def change
    remove_column :requests, :request_type
  end
end
