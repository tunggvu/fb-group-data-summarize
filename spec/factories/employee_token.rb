# frozen_string_literal: true

FactoryBot.define do
  factory :employee_token do
    token { JWT.encode({employee_id: employee.id, token_expired_at: Settings.employee_tokens.expires_in.second.from_now}.as_json,
      OpenSSL::PKey::RSA.new(ENV["SECRET_JWT"]), "RS256")
    }

    expired_at { Settings.employee_tokens.expires_in.second.from_now }
    association :employee
  end
end
