# frozen_string_literal: true

module Entities
  class LevelMember < Entities::Level
    with_options(override: true) do
      expose :skill_id, as: :id
      expose :skill_name, as: :name
      unexpose :id, :name, :rank, :logo
      expose :skill_logo, format_with: :full_url, as: :logo
      expose :level do
        expose :id, :name, :rank
        expose :logo, format_with: :full_url
      end
    end
  end
end
