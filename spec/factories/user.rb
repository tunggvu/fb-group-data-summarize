# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Name.name.remove(" ") + "@gmail.com" }
    password { "123456" }
  end
end
