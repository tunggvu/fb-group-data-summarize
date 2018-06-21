# frozen_string_literal: true

class Effort < ApplicationRecord
  belongs_to :sprint
  belongs_to :employee_skill
  validates :effort, presence: true
end
