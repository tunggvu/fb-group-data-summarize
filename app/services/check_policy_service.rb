# frozen_string_literal: true

class CheckPolicyService
  def initialize(option = {})
    @user = option[:user]
  end

  def can_manage_organization?(organization)
    @user.is_admin? || @user.is_higher_manager?(Organization.levels[:team], organization)
  end

  def can_manage_employee_for?(organization)
    @user.is_admin? || @user.is_higher_manager?(Organization.levels[:clan], organization)
  end

  def can_manage_project?(project)
    return true if project.product_owner.id == @user.id
    org = project.product_owner.organization
    @user.is_admin? || @user.is_higher_manager?(Organization.levels[:clan], org)
  end
end
