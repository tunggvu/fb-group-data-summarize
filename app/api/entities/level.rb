# frozen_string_literal: true

module Entities
  class Level < Grape::Entity
    expose :id, :name, :logo, :rank, :skill_id
  end
end
