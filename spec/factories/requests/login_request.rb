# frozen_string_literal: true

FactoryBot.define do
  factory :login_request, class: Hash do
    email { Faker::Name.name.remove(" ") + "@framgia.com" }
    password "Aa@123456"
  end
end
