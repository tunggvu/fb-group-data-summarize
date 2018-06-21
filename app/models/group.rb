# frozen_string_literal: true

class Group < ApplicationRecord
  has_many :teams, dependent: :destroy
  belongs_to :section
  validates :name, presence: true
end
