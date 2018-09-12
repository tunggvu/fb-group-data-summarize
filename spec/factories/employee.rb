# frozen_string_literal: true

FactoryBot.define do
  factory :employee do
    association :organization
    name { Faker::Name.name }
    employee_code "B120004"
    email { Faker::Name.name.remove(" ") + "@framgia.com" }
    password "Aa@123456"

    trait :admin do
      is_admin true
    end

    trait :skip_callback do
      after(:build) do |instance|
        instance.class.skip_callback(:create, :after, :init_total_effort)
      end

      after(:create) do |instance|
        instance.class.set_callback(:create, :after, :init_total_effort)
      end
    end
  end
end
