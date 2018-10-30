#frozen_string_literal: true

module Entities
  class Profile < Entities::EmployeeDetail
    expose :owned_projects, with: Entities::BaseProject
    expose :owned_organizations, with: Entities::Organizations
  end
end
