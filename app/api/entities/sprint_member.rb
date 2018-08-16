# frozen_string_literal: true

module Entities
  class SprintMember < Entities::Sprint
    expose :efforts, with: Entities::ProjectEffort, as: :members
  end
end
