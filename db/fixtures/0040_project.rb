# frozen_string_literal: true

10.times do
  Project.seed do |p|
    p.name = Faker::Name.name
    p.product_owner_id = rand(1..15)
  end
end
