# frozen_string_literal: true

module Entities
  class Request < Grape::Entity
    expose :id, :status
    expose :modified_date, format_with: :date
    expose :request_type
    expose :project, with: Entities::BaseProject
    expose :request_pic, with: Entities::Employee
    expose :requester, with: Entities::Employee
  end
end
