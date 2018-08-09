# frozen_string_literal: true

class Project < ApplicationRecord
  belongs_to :product_owner, class_name: Employee.name

  has_many :phases, dependent: :destroy
  has_many :sprints, dependent: :destroy
  has_many :efforts, through: :sprints
  has_many :employee_levels, through: :efforts
  has_many :employees, -> { distinct }, through: :employee_levels

  validates :name, presence: true
end
