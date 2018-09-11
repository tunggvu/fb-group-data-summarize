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

  mount_base64_uploader :logo, ImageUploader

  scope :levels_by_employee, -> (employee_id, skill_id) { joins(:skill, :employee_levels).distinct.where(skill_id: skill_id, employee_levels: {employee_id: employee_id}) }
end
