# frozen_string_literal: true

module Entities
  class EffortDetail < Grape::Entity
    expose :effort
    expose :project_name do |effort|
      effort.sprint.project.name
    end
    expose :employee_id do |effort|
      effort.employee_level.employee_id
    end
    with_options(format_with: :date) do
      expose :start_time do |effort|
        effort.sprint.starts_on
      end
      expose :end_time do |effort|
        effort.sprint.ends_on
      end
    end
  end
end
