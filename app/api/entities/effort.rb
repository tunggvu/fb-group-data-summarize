#frozen_string_literal: true

module Entities
  class Effort < Grape::Entity
    expose :id, :effort
    expose :employee_level, with: Entities::EmployeeLevel
  end
end
