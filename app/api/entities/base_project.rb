# frozen_string_literal: true

module Entities
  class BaseProject < Grape::Entity
    expose :id, :name, :description, :starts_on
    expose :logo, format_with: :full_url
    expose :product_owner_id
  end
end
