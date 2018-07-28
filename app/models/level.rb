# frozen_string_literal: true

class Level < ApplicationRecord
  has_many :requirements, dependent: :destroy
  has_many :employee_levels, dependent: :destroy
  has_many :employees, through: :employee_levels
  belongs_to :skill

  validates :name, presence: true
  validates :rank, presence: true
  validates :skill, presence: true

  delegate :name, to: :skill, prefix: true
end
