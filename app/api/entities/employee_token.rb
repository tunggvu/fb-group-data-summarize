# frozen_string_literal: true

module Entities
  class EmployeeToken < Grape::Entity
    expose :token, :expired_at
  end
end
