# frozen_string_literal: true

class EmployeeToken < ApplicationRecord
  belongs_to :employee
  validates :employee, presence: true
  validates :token, presence: true
  validates :expired_at, presence: true

  class << self
    def generate(employee_id, remember = false)
      token = find_or_initialize_by employee_id: employee_id
      token.renew! remember
    end

    def find_by_token(token)
      employee_token = find_by(token: token)
      return nil unless employee_token
      raise APIError::TokenExpired if employee_token&.expired?
      employee_token
    end

    def verify(token)
      JWT.decode(token, OpenSSL::PKey::RSA.new(ENV["PUBLIC_JWT"]), true, { algorithm: "RS256" })
    end
  end

  def renew!(remember = false)
    expired_at = Settings.employee_tokens.public_send(remember ? :expires_in : :short_expires_in).second.from_now
    update_attributes! token: JWT.encode({employee_id: employee.id, token_expired_at: expired_at}.as_json,
      OpenSSL::PKey::RSA.new(ENV["SECRET_JWT"]), "RS256"), expired_at: expired_at
    self
  end

  def expired?
    expired_at <= Time.zone.now
  end
end
