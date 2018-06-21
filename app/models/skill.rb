# frozen_string_literal: true

class Skill < ApplicationRecord
  has_many :employee_skills, dependent: :destroy
  has_many :requirements
  has_many :employees, through: :employee_skills
  validates :name, presence: true
end
