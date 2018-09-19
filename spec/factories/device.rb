#frozen_string_literal: true

FactoryBot.define do
  factory :device do
    association :pic, factory: :employee
    association :project
    serial_code Faker::Code.nric
    os_version Faker::App.semantic_version
    name Faker::Name.name

    trait :laptop do
      device_type :laptop
    end

    trait :pc do
      device_type :pc
    end
  end
end
