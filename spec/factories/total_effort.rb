# frozen_string_literal: true

FactoryBot.define do
  factory :total_effort do
    association :employee
    value { rand(1..100) }
    start_time { Time.zone.now }
    end_time { 10.days.from_now }
  end
end
