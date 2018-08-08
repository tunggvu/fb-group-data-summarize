#frozen_string_literal: true

FactoryBot.define do
  factory :employee_level do
    association :employee
    association :level
  end
end
