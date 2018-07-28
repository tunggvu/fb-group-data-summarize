# frozen_string_literal: true

FactoryBot.define do
  factory :skill do
    name { Faker::Name.name }
    logo "#"
  end
end
