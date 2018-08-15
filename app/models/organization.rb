# frozen_string_literal: true

class Organization < ApplicationRecord
  enum level: {team: 1, clan: 2, section: 3, division: 4}

  has_many :employees, dependent: :nullify
  belongs_to :manager, class_name: Employee.name, optional: true

  delegate :name, to: :manager, prefix: :manager, allow_nil: true

  has_ancestry orphan_strategy: :destroy

  validates :name, presence: true
  validates :level, presence: true

  mount_uploader :logo, ImageUploader

  def full_name
    path.pluck(:name).join(" / ")
  end

  def employee_ids
    (Employee.of_organizations subtree_ids).ids
  end
end
