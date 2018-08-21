# frozen_string_literal: true

class Level < ApplicationRecord
  has_many :requirements, dependent: :restrict_with_error
  has_many :employee_levels, dependent: :restrict_with_error
  has_many :employees, through: :employee_levels
  belongs_to :skill

  validates :name, presence: true
  validates :rank, presence: true
  validates :skill, presence: true

  delegate :name, :logo, to: :skill, prefix: true

  mount_uploader :logo, ImageUploader
end
