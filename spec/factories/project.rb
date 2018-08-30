# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    association :product_owner, factory: :employee
    name { Faker::Name.name }
    logo { "image.png" }
    description { "Description" }
    starts_on { 1.day.ago }
  end
end
