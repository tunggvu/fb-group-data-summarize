# frozen_string_literal: true

module Entities
  class Organization < Entities::BaseOrganization
    expose :manager_name, :employee_ids, :full_name
    expose :logo, format_with: :full_url
  end
end
