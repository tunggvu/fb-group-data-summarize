# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  def project_manager?
    product_owner = @record.product_owner
    admin? || product_owner? || user.is_manager?(product_owner.organization)
  end

  def product_owner?
    user == @record.product_owner
  end

  def view?
    executive? || @record.employees.include?(user)
  end

  class Scope < Scope
    def resolve
      (user.is_admin? || user.organization.level_before_type_cast > 1) ? scope : user.projects
    end
  end
end
