# frozen_string_literal: true

FactoryBot.define do
  factory :phase do
    association :project
    name { Faker::Name.name }
    starts_on { 10.days.ago }
    ends_on { 20.days.from_now }
  end
end
