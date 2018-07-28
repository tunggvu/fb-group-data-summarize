# frozen_string_literal: true

FactoryBot.define do
  factory :requirement do
    association :phase
    association :level
    quantity { Faker::Number.between(1, 10) }
  end
end
