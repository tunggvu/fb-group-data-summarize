FactoryBot.define do
  factory :post do
    title { "MyString" }
    content { "MyText" }
    category { nil }
    user { nil }
    group { nil }
  end
end
