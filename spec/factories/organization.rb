# frozen_string_literal: true

FactoryBot.define do
  factory :organization do
    name { Faker::Name.name }
    level :team
    manager_id 10

    trait :division do
      level :division
    end

    trait :section do
      level :section
    end

    trait :clan do
      level :clan
    end

    trait :team do
      level :team
    end
  end
end
