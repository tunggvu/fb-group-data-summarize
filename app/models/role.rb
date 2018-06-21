# frozen_string_literal: true

class Role < ApplicationRecord
  has_many :employee_roles, dependent: :destroy
  has_many :employees, through: :employee_roles
end
