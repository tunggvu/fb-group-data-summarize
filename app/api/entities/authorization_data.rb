# frozen_string_literal: true

module Entities
  class AuthorizationData < Grape::Entity
    expose :role
    expose :id, as: :user_id
    expose :organization_id
  end
end
