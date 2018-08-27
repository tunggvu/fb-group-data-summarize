# frozen_string_literal: true

class TotalEffort < ApplicationRecord
  belongs_to :employee

  validates :start_time, :end_time, presence: true
  validates :value, presence: true, numericality: { only_integer: true,
    greater_than_or_equal_to: 0 }
  validate :validate_end_time_after_start_time

  private

  def validate_end_time_after_start_time
    return unless start_time && end_time && start_time >= end_time
    errors.add :end_time, "must be after the start time"
  end
end
