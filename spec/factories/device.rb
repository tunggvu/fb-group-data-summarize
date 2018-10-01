#frozen_string_literal: true

FactoryBot.define do
  factory :device do
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

    trait :skip_callback do
      after(:build) do |instance|
        instance.class.skip_callback(:create, :after, :create_first_request)
      end

      after(:create) do |instance|
        instance.class.set_callback(:create, :after, :create_first_request)
      end
    end
  end
end
