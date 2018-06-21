# frozen_string_literal: true

class Division < ApplicationRecord
  validates :name, presence: true
  has_many :sections, dependent: :destroy
end
