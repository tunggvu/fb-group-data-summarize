# frozen_string_literal: true

module Entities
  class ProjectDetail < Entities::Project
    expose :current_sprint, with: Entities::BaseSprint
    expose :phases, with: Entities::Phase
  end
end
