# frozen_string_literal: true

FactoryBot.define do
  factory :sprint do
    association :project
    association :phase
    name { Faker::Name.name }
    start_time { Time.zone.now }
    end_time { 10.days.from_now }
  end
end
