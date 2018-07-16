# frozen_string_literal: true

class Project < ApplicationRecord
  has_many :phases, dependent: :destroy
  has_many :sprints, dependent: :destroy
  belongs_to :product_owner, class_name: Employee.name
  validates :name, presence: true
end
