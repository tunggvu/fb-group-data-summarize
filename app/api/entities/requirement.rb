# frozen_string_literal: true

module Entities
  class Requirement < Grape::Entity
    expose :id, :quantity, :phase_id, :skill_level, :skill_name
  end
end
