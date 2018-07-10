# frozen_string_literal: true

every 1.minute do
  rake "project_feature:send_message_for_reviewer"
end

every :day, at: ["08:50 am", "04:45 pm"] do
  rake "project_feature:reminder"
end
