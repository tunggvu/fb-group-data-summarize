# frozen_string_literal: true

MAX_TIME = 5
MAX_DAY_AGO = 6
statuses = Request.statuses.slice(:approved, :rejected)

Device.all.each do |device|
  MAX_TIME.times.each do |n|
    project = Project.all.sample
    Request.seed do |r|
      r.device = device
      r.project = project
      r.request_pic = project.employees.sample
      r.requester = project.product_owner
      r.modified_date = (MAX_DAY_AGO - n).days.ago
      r.status = n == MAX_TIME ? Request.statuses[:pending] : statuses[statuses.keys.sample]
    end
  end
end
