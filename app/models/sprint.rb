# frozen_string_literal: true

class Sprint < ApplicationRecord
  belongs_to :project
  belongs_to :phase

  has_many :efforts, dependent: :destroy

  validates :name, :starts_on, :ends_on, presence: true

  validate :validate_ends_on_after_starts_on
  validate :validate_starts_on_after_ends_on_previous_sprint
  validate :validate_ends_on_after_starts_on_next_sprint

  def previous_sprint
    starts_on = persisted? ? starts_on_was : self.starts_on
    phase.sprints.where("starts_on < ?", starts_on).first
  end

  def next_sprint
    starts_on = persisted? ? starts_on_was : self.starts_on
    phase.sprints.where("starts_on > ?", starts_on).last
  end

  private

  def validate_ends_on_after_starts_on
    return unless starts_on && ends_on && (starts_on >= ends_on)
    errors.add :ends_on, I18n.t("models.sprint.invalid_starts_on_ends_on")
  end

  def validate_starts_on_after_ends_on_previous_sprint
    return unless previous_sprint && previous_sprint.ends_on >= starts_on
    errors.add :starts_on, I18n.t("models.sprint.invalid_starts_on")
  end

  def validate_ends_on_after_starts_on_next_sprint
    return unless next_sprint && next_sprint.starts_on <= ends_on
    errors.add :ends_on, I18n.t("models.sprint.invalid_ends_on")
  end
end
