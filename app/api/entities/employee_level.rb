#frozen_string_literal: true

module Entities
  class EmployeeLevel < Grape::Entity
    expose :name
    expose :level, with: Entities::LevelMember, as: :skill
  end
end
