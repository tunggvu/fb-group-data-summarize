# frozen_string_literal: true

class Phase < ApplicationRecord
  belongs_to :project
  has_many :sprints, -> { order(starts_on: :desc) }, dependent: :destroy
  has_many :requirements, dependent: :destroy
  validates :name, presence: true

  class << self
    def includes_detail
      includes(
        {
          requirements: { level: :skill }
        },
        {
          sprints: {
            efforts: {
              employee_level: [{ level: :skill }, :employee]
            }
          }
        }
      )
    end
  end
end
