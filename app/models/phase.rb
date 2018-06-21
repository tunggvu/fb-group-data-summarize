# frozen_string_literal: true

class Phase < ApplicationRecord
  belongs_to :project
  has_many :sprints, dependent: :destroy
  has_many :requirements
  validates :name, presence: true
end
