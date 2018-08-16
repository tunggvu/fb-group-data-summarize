# frozen_string_literal: true

module Entities
  class ProjectDetail < Grape::Entity
    expose :id, :name, :description
    expose :logo do |project|
      project.logo.url
    end
    # need update expose to started_at
    expose :created_at, as: :creation_time
    expose :product_owner, with: Entities::Employee
    expose :current_sprint, with: Entities::BaseSprint
    expose :phases, with: Entities::Phase
  end
end
