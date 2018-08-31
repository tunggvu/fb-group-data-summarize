# frozen_string_literal: true

class EmployeeLevel < ApplicationRecord
  belongs_to :level
  belongs_to :employee

  has_many :efforts

  delegate :name, to: :employee, prefix: false

  scope :find_by_employee_and_level, ->(arr) do
    arr.map do |ele|
      where(employee_id: ele[:employee_id], level_id: ele[:level_id])
    end.inject(:or)
  end
end
