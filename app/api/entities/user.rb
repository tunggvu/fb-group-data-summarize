# frozen_string_literal: true

module Entities
  class User < Grape::Entity
    expose :id, :name, :email, :birthday
    expose :avatar, format_with: :full_url
  end
end
