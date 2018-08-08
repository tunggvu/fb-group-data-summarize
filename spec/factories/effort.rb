#frozen_string_literal: true

FactoryBot.define do
  factory :effort do
    association :sprint
    association :employee_level
    effort { rand(1..100) }
  end
end
