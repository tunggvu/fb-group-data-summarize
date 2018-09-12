# frozen_string_literal: true

class Effort < ApplicationRecord
  belongs_to :sprint
  belongs_to :employee_level

  validates :effort, presence: true, numericality: { only_integer: true,
    greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validate :employee_must_be_unique_in_sprint, on: :create

  delegate :project, to: :sprint
  delegate :employee, to: :employee_level
  delegate :level, to: :employee_level

  after_create :update_total_efforts_after_create
  after_update :update_total_efforts_after_update
  after_destroy :update_total_efforts_after_delete

  scope :relate_to_period, ->(start_time, end_time) do
    joins(:sprint).where.not("sprints.starts_on > ? OR sprints.ends_on < ?", end_time, start_time)
  end

  private

  def employee_must_be_unique_in_sprint
    return unless sprint && employee_level && sprint.employees.ids.include?(employee_level.employee_id)
    errors.add :base, I18n.t("models.effort.employee_must_be_unique_in_sprint")
  end

  def update_total_efforts_after_create
    total_efforts = TotalEffort.finding_with_effort_time(sprint.starts_on,
      sprint.ends_on, employee_level.employee_id)
    return if total_efforts.size == 0
    if total_efforts.size == 1
      total_efforts.first.update_effort_wrapped self
    else
      total_efforts.first.update_effort_start_after self
      total_efforts.last.update_effort_end_before self
      total_efforts[1..-2].each do |total_effort|
        total_effort.update_effort_wrapping self
      end
    end
  end

  def update_total_efforts_after_update
    total_efforts = TotalEffort.finding_with_effort_time(sprint.starts_on,
      sprint.ends_on, employee_level.employee_id)
    ActiveRecord::Base.transaction do
      total_efforts.each do |total_effort|
        old_effort = self.previous_changes[:effort][0]
        total_effort.update_attributes(value: total_effort.value - old_effort + effort)
      end
    end
  end

  def update_total_efforts_after_delete
    total_efforts = TotalEffort.finding_with_effort_time(sprint.starts_on,
      sprint.ends_on, employee_level.employee_id)
    ActiveRecord::Base.transaction do
      total_efforts.each do |total_effort|
        total_effort.update_attributes value: total_effort.value - effort_was
      end
    end
  end
end
