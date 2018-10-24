# frozen_string_literal: true

class Requirement < ApplicationRecord
  belongs_to :level
  belongs_to :phase

  delegate :name, to: :level, prefix: true

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :level_id, uniqueness: { scope: :phase_id }
end
