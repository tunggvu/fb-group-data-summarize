# frozen_string_literal: true

class Team < ApplicationRecord
  belongs_to :group
  has_many :employees, dependent: :destroy
  validates :name, presence: true
end
