# frozen_string_literal: true

FactoryBot.define do

  factory :organization do
    name { Faker::Name.name }
    level "clan"
    email { Faker::Internet.email }
    password "Aa@123456"
  end
end
