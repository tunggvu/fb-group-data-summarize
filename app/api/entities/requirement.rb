# frozen_string_literal: true

module Entities
  class Requirement < Grape::Entity
    expose :id, :quantity, :phase_id
    expose :level_name, as: :skill_level
    expose :skill_name do |requirement|
      requirement.level.skill_name
    end
  end
end
