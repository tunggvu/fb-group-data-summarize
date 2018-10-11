# frozen_string_literal: true

module Entities
  class Request < Grape::Entity
    expose :id, :status, :device_id
    expose :modified_date, format_with: :date
    expose :project, with: Entities::DeviceProject
    expose :request_pic, with: Entities::Employee
    expose :requester, with: Entities::Employee
  end
end
