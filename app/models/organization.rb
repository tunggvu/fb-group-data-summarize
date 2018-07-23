# frozen_string_literal: true

class Organization < ApplicationRecord
  has_many :employees, dependent: :nullify

  has_ancestry orphan_strategy: :destroy

  validates :name, presence: true
  validates :manager_id, presence: true
  validates :level, presence: true

  enum level: {team: 1, clan: 2, section: 3, division: 4}
end
