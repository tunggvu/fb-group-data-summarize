# frozen_string_literal: true

FactoryBot.define do
  factory :employee do
    association :organization
    name { Faker::Name.name }
    employee_code "B120004"
    email { Faker::Name.name.remove(" ") + "@framgia.com" }
    password "Aa@123456"
  end
end
