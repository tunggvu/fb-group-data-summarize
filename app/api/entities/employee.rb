# frozen_string_literal: true

module Entities
  class Employee < Grape::Entity
    expose :id, :organization_id, :name, :employee_code, :email, :birthday, :phone
    expose :avatar do |employee|
      ActionController::Base.helpers.image_url(employee.avatar.url)
    end
  end
end
