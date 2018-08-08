# frozen_string_literal: true

class EmployeeLevel < ApplicationRecord
  belongs_to :level
  belongs_to :employee

  has_many :efforts

  delegate :name, to: :employee, prefix: false
end
