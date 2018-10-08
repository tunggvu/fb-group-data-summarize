# frozen_string_literal: true

class DevicePolicy < ApplicationPolicy
  def device_owner?
    user == @record.project.product_owner || user == @record.pic || admin?
  end

  def user_can_borrow?
    user.is_other_product_owner?(@record.project) || admin?
  end
end
