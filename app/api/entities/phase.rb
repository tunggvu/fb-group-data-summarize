# frozen_string_literal: true

module Entities
  class Phase < Grape::Entity
    expose :id, :name
    expose :requirements, with: Entities::Requirement
    expose :sprints, with: Entities::SprintMember
  end
end
