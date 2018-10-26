# frozen_string_literal: true

namespace :chatwork_bot do
  desc "incomming request chatwork"
  task accept_request: :environment do
    ChatWork.api_key = ENV["CHATWORK_API_KEY"]
    requests = ChatWork::IncomingRequest.get&.pluck(:request_id) || []
    requests.each do |request_id|
      ChatWork::IncomingRequest.approve(request_id: request_id)
    end
  end
end
