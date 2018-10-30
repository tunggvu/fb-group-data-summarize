# frozen_string_literal: true

module Entities
  class EmployeeDetail < Entities::Employee
    expose :levels, with: Entities::LevelMember, as: :skills do |profile|
      profile.levels.includes(:skill)
    end
    expose :devices, with: Entities::BaseDevice do |profile|
      profile.devices.includes(:project)
    end
    expose :organization, with: Entities::Organizations
    expose :projects, with: Entities::BaseProject
  end
end
