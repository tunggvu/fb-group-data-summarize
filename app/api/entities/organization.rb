# frozen_string_literal: true

module Entities
  class Organization < Entities::BaseOrganization
    expose :manager_name, :employee_ids, :full_name, :logo
  end
end
