# frozen_string_literal: true

FactoryBot.define do
  factory :sprint do
    association :project
    association :phase
    name { Faker::Name.name }
    starts_on { Date.current }
    ends_on { 10.days.from_now }
  end
end
