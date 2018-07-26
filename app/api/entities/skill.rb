# frozen_string_literal: true

module Entities
  class Skill < Grape::Entity
    expose :id, :name, :level
  end
end
