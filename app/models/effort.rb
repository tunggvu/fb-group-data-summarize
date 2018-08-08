# frozen_string_literal: true

class Effort < ApplicationRecord
  belongs_to :sprint
  belongs_to :employee_level

  validates :effort, presence: true, numericality: { only_integer: true,
    greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
end
