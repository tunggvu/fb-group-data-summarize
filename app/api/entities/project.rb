# frozen_string_literal: true

module Entities
  class Project < Grape::Entity
    expose :id, :name, :description
    expose :logo do |project|
      project.logo.url
    end
    expose :created_at, as: :started_at, format_with: :utc
    expose :product_owner, with: Entities::Employee
  end
end
