# frozen_string_literal: true

class DevicePolicy < ApplicationPolicy
  def device_owner?
    user == @record.project.product_owner || user == @record.pic || admin?
  end
end
