# frozen_string_literal: true

module Entities
  class Project < Grape::Entity
    expose :id, :name, :description
    expose :logo, format_with: :full_url
    expose :created_at, as: :started_at, format_with: :utc
    expose :product_owner, with: Entities::Employee
  end
end
