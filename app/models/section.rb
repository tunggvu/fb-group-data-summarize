# frozen_string_literal: true

class Section < ApplicationRecord
  belongs_to :division
  has_many :groups, dependent: :destroy
  validates :name, presence: true
end
