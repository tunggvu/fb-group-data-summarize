# frozen_string_literal: true

10.times do
  Project.seed do |p|
    p.name = Faker::Name.name
    p.product_owner_id = rand(1..15)
    p.starts_on = 2.days.ago
  end
end
