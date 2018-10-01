# frozen_string_literal: true

module Entities
  class Request < Grape::Entity
    expose :id, :status
    expose :modified_date, format_with: :date
    expose :project, with: Entities::BaseProject
    expose :request_pic, with: Entities::Employee
    expose :requester, with: Entities::Employee
    expose :device, with: Entities::Device
  end
end
