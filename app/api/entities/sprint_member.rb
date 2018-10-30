# frozen_string_literal: true

module Entities
  class SprintMember < Entities::Sprint
    expose :efforts, with: Entities::ProjectEffort, as: :members
    expose :phase_id
  end
end
