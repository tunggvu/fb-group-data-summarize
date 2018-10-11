# frozen_string_literal: true

class Phase < ApplicationRecord
  belongs_to :project

  has_many :sprints, -> { order(starts_on: :desc) }, dependent: :destroy
  has_many :requirements, dependent: :destroy

  validates :name, :starts_on, :ends_on, presence: true
  # validates :starts_on, uniqueness: { scope: :project }
  validate :validate_ends_on_after_starts_on
  # validate :validate_starts_on_after_ends_on_previous_phase
  # validate :validate_ends_on_after_starts_on_next_phase

  def previous_phase
    starts_on = persisted? ? starts_on_was : self.starts_on
    project.phases.where("starts_on < ?", starts_on).first
  end

  def next_phase
    starts_on = persisted? ? starts_on_was : self.starts_on
    project.phases.where("starts_on > ?", starts_on).last
  end

  class << self
    def includes_detail
      includes(
        {
          requirements: { level: :skill }
        },
        {
          sprints: {
            efforts: {
              employee_level: [{ level: :skill }, :employee]
            }
          }
        }
      )
    end
  end

  private

  def validate_ends_on_after_starts_on
    return if starts_on.blank? || ends_on.blank? || starts_on < ends_on
    errors.add :ends_on, I18n.t("models.phase.invalid_starts_on_ends_on")
  end

  def validate_starts_on_after_ends_on_previous_phase
    return if starts_on.blank? || previous_phase.blank? || previous_phase.ends_on < starts_on
    errors.add :starts_on, I18n.t("models.phase.invalid_starts_on")
  end

  def validate_ends_on_after_starts_on_next_phase
    return if ends_on.blank? || next_phase.blank? || next_phase.starts_on > ends_on
    errors.add :ends_on, I18n.t("models.phase.invalid_ends_on")
  end
end
