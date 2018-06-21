# frozen_string_literal: true

class Employee < ApplicationRecord
  belongs_to :team
  has_many :employee_skills, dependent: :destroy
  has_many :employee_roles, dependent: :destroy
  has_many :skills, through: :employee_skills
  has_many :roles, through: :employee_roles
  validates :name, presence: true
  validates :employee_code, presence: true
end
