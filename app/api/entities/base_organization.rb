# frozen_string_literal: true

module Entities
  class BaseOrganization < Grape::Entity
    expose :id, :parent_id, :manager_id, :level, :name
    expose :children, with: Entities::BaseOrganization
  end
end
