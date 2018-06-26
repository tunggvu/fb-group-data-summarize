# frozen_string_literal: true

class CreateProjectChatRoom < ActiveRecord::Migration[5.2]
  def change
    create_table :project_chat_rooms do |t|
      t.text :last_message_id, default: ""
      t.text :chat_room_id
    end
  end
end
