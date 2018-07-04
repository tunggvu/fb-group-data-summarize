# frozen_string_literal: true

FactoryBot.define do
  factory :employee_token do
    token { SecureRandom.hex(Settings.employee_tokens.token.secure_length) }
    expired_at { Settings.employee_tokens.expires_in.second.from_now }
    association :employee
  end
end
