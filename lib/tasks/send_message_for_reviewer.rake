# frozen_string_literal: true
# encoding: utf-8
namespace :project_feature do
  desc "check_mention"
  task send_message_for_reviewer: :environment do
    ChatWork.api_key = ENV["CHATWORK_API_KEY"]
    messages = ChatWork::Message.get(room_id: ENV["ROOM_ID"], force: true)
    last_message_id = ProjectChatRoom.find_or_create_by(chat_room_id: ENV["ROOM_ID"]).last_message_id
    if last_message_id == ""
      ProjectChatRoom.first.update(last_message_id: messages.last.message_id)
    else
      messages.each_with_index do |message, index|
        next unless (message.body =~ (/\[To:#{ENV["BOT_ID"]}\]/) && Integer(message.message_id) > Integer(last_message_id))
        case message.body
        when /review/i
          message.body =~ /be/i ? send_message(message, "backend") : send_message(message, "frontend")
        end
      end
      ProjectChatRoom.first.update(last_message_id: last_message_id)
    end
  end

  def send_message(message, type)
    members = []
    Settings.send("members_#{type}_id").select { |i| i != "#{message.account.account_id}" }.sample(3).each { |item|
      members.append("[To:#{item}]")
    }
    members.append("[To:#{Settings.leader_backend_id}]", "[To:#{Settings.leader_frontend_id}]")
    ChatWork::Message.create(room_id: ENV["ROOM_ID"], body: (message.body.remove("[To:#{ENV["BOT_ID"]}] #{ENV["BOT_NAME"]}") + "\n" + member.join(" ")))
  end
end
