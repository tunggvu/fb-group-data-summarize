# frozen_string_literal: true

module Entities
  class Skill < Grape::Entity
    expose :name, :level
  end
end
