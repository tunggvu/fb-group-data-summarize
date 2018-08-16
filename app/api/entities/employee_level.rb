#frozen_string_literal: true

module Entities
  class EmployeeLevel < Grape::Entity
    expose :name
    expose :employee_id, as: :id
    expose :level, with: Entities::LevelMember, as: :skill
  end
end
