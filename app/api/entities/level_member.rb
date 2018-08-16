# frozen_string_literal: true

module Entities
  class LevelMember < Entities::Level
    with_options(override: true) do
      expose :skill_id, as: :id
      expose :skill_name, as: :name
      unexpose :id, :name, :rank, :logo
      expose :logo do |level_member|
        level_member.skill_logo.url
      end
      expose :level do
        expose :id, :name, :rank, :logo
      end
    end
  end
end
