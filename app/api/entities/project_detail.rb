# frozen_string_literal: true

module Entities
  class ProjectDetail < Grape::Entity
    expose :id, :name, :description, :starts_on
    expose :logo, format_with: :full_url
    expose :product_owner, with: Entities::Employee
    expose :current_sprint, with: Entities::BaseSprint
    expose :phases, with: Entities::Phase
  end
end
