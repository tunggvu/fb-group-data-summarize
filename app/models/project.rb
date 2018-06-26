# frozen_string_literal: true

class Project < ApplicationRecord
  has_many :phases, dependent: :destroy
  has_many :sprints, dependent: :destroy
  validates :name, presence: true
end
