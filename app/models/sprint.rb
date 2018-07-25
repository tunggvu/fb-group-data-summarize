# frozen_string_literal: true

class Sprint < ApplicationRecord
  belongs_to :project
  belongs_to :phase
  has_many :efforts, dependent: :destroy
  validates :name, :start_time, :end_time, presence: true
  validate :validate_end_time_after_start_time

  private
  def validate_end_time_after_start_time
    if start_time.present? && end_time.present? && start_time > end_time
      errors.add :end_time, "must be after the start time"
    end
  end
end
