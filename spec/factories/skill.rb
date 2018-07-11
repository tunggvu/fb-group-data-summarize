# frozen_string_literal: true

FactoryBot.define do
  factory :skill do
    name { Faker::Name.name }
    level ["Junior", "Middle", "Senior"].sample
  end
end
