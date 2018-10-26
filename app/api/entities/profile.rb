#frozen_string_literal: true

module Entities
  class Profile < Entities::Employee
    expose :organization, with: Entities::BaseOrganization
    expose :owned_projects, with: Entities::BaseProject
    expose :owned_organizations, with: Entities::Organizations
    expose :projects, with: Entities::BaseProject
    expose :levels, with: Entities::LevelMember, as: :skills do |profile|
      profile.levels.includes(:skill)
    end
    expose :devices, with: Entities::BaseDevice do |profile|
      profile.devices.includes(:project)
    end
  end
end
