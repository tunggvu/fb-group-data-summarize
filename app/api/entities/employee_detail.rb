# frozen_string_literal: true

module Entities
  class EmployeeDetail < Grape::Entity
    expose :id, :name, :employee_code, :email, :birthday, :phone, :role
    expose :avatar, format_with: :full_url
    expose :levels, with: Entities::LevelMember, as: :skills
    expose :organization, with: Entities::Organizations
    expose :projects, with: Entities::BaseProject
    expose :devices, with: Entities::BaseDevice
  end
end
