# frozen_string_literal: true

class AddChatworkInfoToEmployees < ActiveRecord::Migration[5.2]
  def change
    add_column :employees, :chatwork_room_id, :integer, default: nil
    add_column :employees, :chatwork_status, :integer, default: :off
  end
end
