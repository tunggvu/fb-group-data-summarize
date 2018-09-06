# frozen_string_literal: true

module Entities
  class Phase < Grape::Entity
    expose :id, :name, :starts_on, :ends_on
    expose :requirements, with: Entities::Requirement
    expose :sprints, with: Entities::SprintMember
  end
end
