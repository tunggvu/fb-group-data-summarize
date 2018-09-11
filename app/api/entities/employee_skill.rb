# frozen_string_literal: true

module Entities
  class EmployeeSkill < Grape::Entity
    with_options(override: true) do
      expose :id, :name
      expose :skills, with: Entities::LevelSkill do |employee|
        employee.skills.distinct
      end
    end
  end
end
