# frozen_string_literal: true

class Requirement < ApplicationRecord
  belongs_to :level
  belongs_to :phase

  delegate :name, to: :level, prefix: true
end
