# frozen_string_literal: true

class Sprint < ApplicationRecord
  belongs_to :project
  belongs_to :phase
  has_many :efforts, dependent: :destroy
  validates :name, :starts_on, :ends_on, presence: true
  validate :validate_ends_on_after_starts_on

  private

  def validate_ends_on_after_starts_on
    return unless starts_on && ends_on && starts_on >= ends_on
    errors.add :ends_on, "must be after the starts on"
  end
end
