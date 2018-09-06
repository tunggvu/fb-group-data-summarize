# frozen_string_literal: true

class Phase < ApplicationRecord
  belongs_to :project

  has_many :sprints, -> { order(starts_on: :desc) }, dependent: :destroy
  has_many :requirements, dependent: :destroy

  validates :name, :starts_on, :ends_on, presence: true
  validate :validate_ends_on_after_starts_on

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
    return unless starts_on && ends_on && starts_on >= ends_on
    errors.add :ends_on, I18n.t("models.sprint.invalid_starts_on_ends_on")
  end
end
