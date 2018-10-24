# frozen_string_literal: true

module Entities
  class BasePhase < Grape::Entity
    expose :id, :name
  end
end
