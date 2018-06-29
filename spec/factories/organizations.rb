# frozen_string_literal: true

FactoryBot.define do
  factory :organization do
    name "Team"
    level :team
    manager_id 1

    trait :division do
      name "Division"
      level :division
    end

    trait :group do
      name "Group"
      level :clan
    end
  end
end
