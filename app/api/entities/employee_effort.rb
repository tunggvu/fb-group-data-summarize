# frozen_string_literal: true

module Entities
  class EmployeeEffort < Grape::Entity
    expose :name, as: :employee_name
    expose :id, as: :employee_id
    expose :total_efforts, using: Entities::TotalEffort
  end
end
