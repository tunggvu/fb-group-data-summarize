# frozen_string_literal: true

class Organization < ApplicationRecord
  belongs_to :parent, class_name: Organization.name, optional: true
  has_many :children, class_name: Organization.name, foreign_key: :parent_id, dependent: :destroy
  has_many :employees, dependent: :nullify
  validates :name, presence: true
  validates :manager_id, presence: true
  validates :level, presence: true

  enum level: {team: 1, clan: 2, section: 3, division: 4}

  scope :top_organization, -> { where parent_id: nil }
end
