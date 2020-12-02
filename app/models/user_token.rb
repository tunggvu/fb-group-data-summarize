# frozen_string_literal: true

class UserToken < ApplicationRecord
  belongs_to :user
  validates :token, presence: true
  validates :expired_at, presence: true

  class << self
    def generate(user_id, remember = false)
      token = find_or_initialize_by user_id: user_id
      token.renew! remember
    end

    def find_by_token(token)
      user_token = find_by(token: token)
      return nil unless user_token
      raise APIError::TokenExpired if user_token&.expired?
      user_token
    end

    def verify(token)
      JWT.decode(token, OpenSSL::PKey::RSA.new(ENV["PUBLIC_JWT"]), true, { algorithm: "RS256" })
    end
  end

  def renew!(remember = false)
    expired_at = Settings.user_tokens.public_send(remember ? :expires_in : :short_expires_in).second.from_now
    update_attributes! token: JWT.encode({employee_id: user.id, token_expired_at: expired_at}.as_json,
      OpenSSL::PKey::RSA.new(ENV["SECRET_JWT"]), "RS256"), expired_at: expired_at
    self
  end

  def expired?
    expired_at <= Time.zone.now
  end
end
