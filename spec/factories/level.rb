# frozen_string_literal: true

FactoryBot.define do
  factory :level do
    rank { Faker::Number.number 5 }
    name { Faker::Name.name }
    logo "#"
    association :skill
  end
end
