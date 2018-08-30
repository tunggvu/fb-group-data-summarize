# frozen_string_literal: true

module Entities
  class Project < Grape::Entity
    expose :id, :name, :description, :starts_on
    expose :logo, format_with: :full_url
    expose :product_owner, with: Entities::Employee
  end
end
