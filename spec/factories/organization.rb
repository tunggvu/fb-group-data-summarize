# frozen_string_literal: true

FactoryBot.define do
  factory :organization do
    name "Division 1"
    manager_id 1
    level "division"
    trait :has_parent do
      association :parent, factory: :organization, optional: true
    end
  end
end
