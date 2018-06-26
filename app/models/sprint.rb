# frozen_string_literal: true

class Sprint < ApplicationRecord
  belongs_to :project
  belongs_to :phase
  has_many :efforts, dependent: :destroy
  validates :name, :start_time, :end_time, presence: true
end
