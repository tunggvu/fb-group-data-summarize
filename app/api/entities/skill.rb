# frozen_string_literal: true

module Entities
  class Skill < Grape::Entity
    expose :id, :name, :logo
    expose :levels, using: Entities::Level
  end
end
