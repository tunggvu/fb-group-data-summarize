# frozen_string_literal: true

module Entities
  class Project < Grape::Entity
    expose :id, :name
    expose :product_owner, with: Entities::Employee
    expose :phases, with: Entities::Phase
  end
end