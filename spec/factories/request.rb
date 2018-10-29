# frozen_string_literal: true

FactoryBot.define do
  factory :request do
    association :device
    association :project
    association :request_pic, factory: :employee
    association :requester, factory: :employee
    modified_at { Faker::Time.backward 30 }

    trait :pending do
      status :pending
    end

    trait :approved do
      status :approved
    end

    trait :confirmed do
      status :confirmed
    end

    trait :rejected do
      status :rejected
    end

    trait :skip_validate do
      to_create { |instance| instance.save(validate: false) }
    end
  end
end
