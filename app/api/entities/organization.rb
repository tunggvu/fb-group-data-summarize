# frozen_string_literal: true

module Entities
  class Organization < Grape::Entity
    expose :id, :name, :parent_id, :manager_id, :level
    expose :children, with: Entities::Organization
  end
end
