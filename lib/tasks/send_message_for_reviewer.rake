# frozen_string_literal: true

namespace :project_feature do
  desc "check_mention"
  task send_message_for_reviewer: :environment do
    MEMBER_SEND = []
    Settings.members_id.sample(3).each { |item| MEMBER_SEND.append("[To:#{item}]") if item.present? }
    ChatWork.api_key = ENV["API_KEY"]
    messages = ChatWork::Message.get(room_id: ENV["ROOM_ID"], force: true)
    last_message_id = ProjectChatRoom.find_or_create_by(chat_room_id: ENV["ROOM_ID"]).last_message_id
    if last_message_id == ""
      ProjectChatRoom.first.update(last_message_id: messages.last.message_id)
    else
      messages.each_with_index do |item, index|
        if(item.body.include?("[To:#{ENV["BOT_ID"]}]") && Integer(item.message_id) > Integer(last_message_id))
          last_message_id = item.message_id
          ChatWork::Message.create(room_id: ENV["ROOM_ID"], body: (item.body.remove("[To:#{ENV["BOT_ID"]}] #{ENV["BOT_NAME"]}") + "\n" + MEMBER_SEND.reduce(:+).to_s))
        end
      end
      ProjectChatRoom.first.update(last_message_id: last_message_id)
    end
  end
end
