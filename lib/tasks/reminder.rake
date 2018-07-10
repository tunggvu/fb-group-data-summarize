# frozen_string_literal: true

namespace :project_feature do
  desc "reminder meeting and report"
  task reminder: :environment do
    ChatWork.api_key = ENV["API_KEY"]
    case Time.now.strftime("%H:%M")
    when "8:50"
      ChatWork::Message.create(room_id: ENV["ROOM_ID"], body: "[toall]" + "\n" + "Reminder: We have meeting at 9 am")
    when "16:45"
      ChatWork::Message.create(room_id: ENV["ROOM_ID"], body: "[toall]" + "\n" + "Reminder: Please report your today's work")
    end
  end
end
