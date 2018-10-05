# frozen_string_literal: true

module Entities
  class EmployeeToken < Grape::Entity
    expose :token do |employee_token|
      "Bearer #{employee_token.token}"
    end
    expose :expired_at
    expose :authorization, using: Entities::AuthorizationData, merge: true do |employee_token|
      employee_token.employee
    end
  end
end
