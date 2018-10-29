# frozen_string_literal: true

class EmployeePolicy < ApplicationPolicy
  def self_or_subordinate?
    user == record || admin? || user.subordinates.include?(record)
  end
end
