# frozen_string_literal: true

FactoryBot.define do
  factory :login_request, class: Hash do
    email { Faker::Name.name.remove(" ") + "@gmail.com" }
    password { "123456" }
  end
end
