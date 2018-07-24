# frozen_string_literal: true

class Requirement < ApplicationRecord
  belongs_to :skill
  belongs_to :phase

  delegate :name, :level, to: :skill, prefix: true
end
