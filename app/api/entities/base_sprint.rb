# frozen_string_literal: true

module Entities
  class BaseSprint < Grape::Entity
    expose :id, :name
  end
end
