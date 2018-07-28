# frozen_string_literal: true

class Skill < ApplicationRecord
  has_many :levels, dependent: :destroy
  validates :name, presence: true

  accepts_nested_attributes_for :levels
end
