# frozen_string_literal: true

module Entities
  class UserToken < Grape::Entity
    expose :token do |user_token|
      "Bearer #{user_token.token}"
    end
    expose :expired_at
    expose :authorization, using: Entities::AuthorizationData, merge: true do |user_token|
      user_token.user
    end
  end
end
