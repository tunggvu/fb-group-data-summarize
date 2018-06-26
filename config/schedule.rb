# frozen_string_literal: true

every 1.minute do
  rake "project_feature:send_message_for_reviewer"
end
