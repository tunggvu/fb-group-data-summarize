# frozen_string_literal: true

class OrganizationPolicy < ApplicationPolicy
  def organization_manager?
    organization = @record
    admin? || user.is_manager?(organization)
  end
end
