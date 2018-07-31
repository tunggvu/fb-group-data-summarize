# frozen_string_literal: true

module Entities
  class Employee < Grape::Entity
    expose :id, :organization_id, :name, :employee_code, :email, :birthday, :phone, :avatar
  end
end
