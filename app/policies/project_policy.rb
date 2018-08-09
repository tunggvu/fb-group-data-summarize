# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  def project_manager?
    product_owner = @record.product_owner
    admin? || project_owner? || user.is_manager?(product_owner.organization)
  end

  def project_owner?
    user == @record.product_owner
  end

  def view?
    executive? || @record.employees.include?(user)
  end
end