# frozen_string_literal: true

class Effort < ApplicationRecord
  belongs_to :sprint
  belongs_to :employee_level

  validates :effort, presence: true, numericality: { only_integer: true,
    greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :employee_level, uniqueness: { scope: :sprint }

  delegate :project, to: :sprint
  delegate :employee, to: :employee_level
  delegate :level, to: :employee_level

  scope :relate_to_period, ->(start_time, end_time) do
    joins(:sprint).where.not("sprints.starts_on > ? OR sprints.ends_on < ?", end_time, start_time)
  end
end
