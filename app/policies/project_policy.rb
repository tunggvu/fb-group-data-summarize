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
    executive? || @record.employees.include?(user) || product_owner?
  end
end
