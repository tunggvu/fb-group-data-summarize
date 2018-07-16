# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    association :product_owner, factory: :employee
    name { Faker::Name.name }
  end
end
