# frozen_string_literal: true

FactoryBot.define do
  factory :organization do
    name { Faker::Name.name }
    level :team
    manager_id 10

    trait :division do
      level :division
    end

    trait :group do
      level :clan
    end
  end
end
