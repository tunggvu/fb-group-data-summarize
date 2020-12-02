# frozen_string_literal: true

module Entities
  class AuthorizationData < Grape::Entity
    expose :id, as: :user_id
  end
end
