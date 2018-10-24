#frozen_string_literal: true

module Entities
  class Profile < Entities::Employee
    expose :levels, with: Entities::LevelMember, as: :skills
    expose :organization, with: Entities::BaseOrganization
    expose :devices, with: Entities::BaseDevice
    expose :owned_projects, with: Entities::BaseProject
    expose :owned_organizations, with: Entities::Organizations
  end
end
