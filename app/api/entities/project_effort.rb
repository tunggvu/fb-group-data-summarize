#frozen_string_literal: true

module Entities
  class ProjectEffort < Grape::Entity
    expose :effort
    expose :employee_level, with: Entities::EmployeeLevel, merge: true
  end
end
