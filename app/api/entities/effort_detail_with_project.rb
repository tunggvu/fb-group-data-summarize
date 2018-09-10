# frozen_string_literal: true

module Entities
  class EffortDetailWithProject < Grape::Entity
      expose :project_name do |effort|
        effort.project.name
      end
      expose :effort, as: :effort_value
      expose :skill do |effort|
        effort.level.skill_name
      end
  end
end
