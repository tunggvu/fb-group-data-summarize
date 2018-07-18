# frozen_string_literal: true

FactoryBot.define do
  factory :phase do
    association :project
    name { Faker::Name.name }
  end
end
