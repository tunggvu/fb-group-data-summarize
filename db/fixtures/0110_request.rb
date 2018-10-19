# frozen_string_literal: true

MAX_TIME = 5
events = [:approve!, :confirm!, :reject!]

Device.all.each do |device|
  MAX_TIME.times.each do |n|
    project = Project.all.sample
    request = Request.create!(
      device: device,
      project: project,
      request_pic: project.employees.sample,
      requester: project.product_owner,
      modified_at: n.days.from_now
    )
    confirmation_token = Request.new_token
    confirmation_digest = Request.digest confirmation_token
    request.update_column(:confirmation_digest, confirmation_digest)
    request.send(events.sample, confirmation_token)
  end
end
