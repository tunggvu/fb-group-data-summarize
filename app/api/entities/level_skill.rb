# frozen_string_literal: true
module Entities
  class LevelSkill < Grape::Entity
    expose :id, :name
    expose :levels, with: Entities::Level do |skill, option|
      ::Level.levels_by_employee(option[:employee_id], skill.id)
    end
  end
end
