# frozen_string_literal: true

module Entities
  class ProjectDetail < Entities::Project
    expose :current_sprint, with: Entities::BaseSprint
    expose :current_phase, with: Entities::BasePhase
    expose :phases, with: Entities::Phase
  end
end
