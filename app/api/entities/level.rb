# frozen_string_literal: true

module Entities
  class Level < Grape::Entity
    expose :id, :name, :rank, :skill_id
    expose :logo, format_with: :full_url
  end
end
