# frozen_string_literal: true

FactoryBot.define do
  factory :request do
    association :device
    association :project
    association :request_pic, factory: :employee
    association :requester, factory: :employee
    modified_date { Faker::Date.backward 30 }
  end
end
