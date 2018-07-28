# frozen_string_literal: true

Phase.all.each do |phase|
  5.times do |n|
    Requirement.seed do |p|
      p.level_id = Faker::Number.between(1, Level.all.size)
      p.phase_id = phase.id
      p.quantity = Faker::Number.between(1, 10)
    end
  end
end
