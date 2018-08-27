# frozen_string_literal: true

module Entities
  class Skill < Grape::Entity
    expose :id, :name
    expose :logo, format_with: :full_url
    expose :levels, using: Entities::Level
  end
end
