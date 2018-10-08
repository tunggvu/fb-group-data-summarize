# frozen_string_literal: true

class TotalEffort < ApplicationRecord
  belongs_to :employee

  validates :start_time, :end_time, presence: true
  validates :value, presence: true, numericality: { only_integer: true,
    greater_than_or_equal_to: 0 }
  validate :validate_end_time_after_start_time
  scope :finding_with_effort_time, ->(starts_on, ends_on, employee_id) do
    where("employee_id = ? AND (start_time < ? AND end_time > ?)", employee_id, ends_on, starts_on)
  end

  # Only use in this case:
  #
  # Total Effort:   |===============|
  # Effort:      |==========|
  #
  def update_effort_end_before(effort)
    sprint = effort.sprint
    return if end_time < sprint.ends_on || start_time <= sprint.starts_on
    employee_id = effort.employee_level.employee_id
    new_value = effort.effort + value
    ActiveRecord::Base.transaction do
      if end_time == sprint.ends_on
        self.update_attributes value: new_value
      else # end_time > sprint.ends_on
        TotalEffort.create! start_time: start_time,
          end_time: sprint.ends_on, value: new_value, employee_id: employee_id
        self.update_attributes start_time: sprint.ends_on + 1.day
      end
    end
  end

  # Only use in this case:
  #
  # Total Effort:   |===============|
  # Effort:                   |==========|
  #
  def update_effort_start_after(effort)
    sprint = effort.sprint
    return if start_time > sprint.starts_on || end_time >= sprint.ends_on
    employee_id = effort.employee_level.employee_id
    new_value = effort.effort + value
    ActiveRecord::Base.transaction do
      if start_time == sprint.starts_on
        self.update_attributes value: new_value
      else # start_time < sprint.starts_on
        TotalEffort.create! start_time: start_time,
          end_time: sprint.starts_on - 1.day, value: value, employee_id: employee_id
        self.update_attributes value: new_value, start_time: sprint.starts_on
      end
    end
  end

  # Only use in this case:
  #
  # Total Effort:     |==========|
  # Effort:        |================|
  #
  def update_effort_wrapping(effort)
    sprint = effort.sprint
    return if start_time < sprint.starts_on && end_time > sprint.ends_on
    self.update_attributes value: value + effort.effort
  end

  # Only use in this case:
  #
  # Total Effort:     |==============|
  # Effort:             |==========|
  #
  def update_effort_wrapped(effort)
    sprint = effort.sprint
    return if start_time > sprint.starts_on || end_time < sprint.ends_on
    employee_id = effort.employee_level.employee_id
    new_value = effort.effort + value
    ActiveRecord::Base.transaction do
      if start_time < sprint.starts_on
        TotalEffort.create! start_time: start_time,
          end_time: sprint.starts_on - 1.day, value: value, employee_id: employee_id
      end
      if end_time > sprint.ends_on
        TotalEffort.create! start_time: sprint.ends_on + 1.day,
          end_time: end_time, value: value, employee_id: employee_id
      end
      self.update_attributes value: new_value, start_time: sprint.starts_on, end_time: sprint.ends_on
    end
  end

  private

  def validate_end_time_after_start_time
    return unless start_time && end_time && start_time > end_time
    errors.add :end_time, "must be after the start time"
  end
end
