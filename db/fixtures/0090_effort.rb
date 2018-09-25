# frozen_string_literal: true

EmployeeLevel.all.each do |el|
  random = Faker::Number.between(1, Sprint.all.size - 20)
  count = Faker::Number.between(5, 10)
  count.times do |n|
    Effort.seed do |e|
      e.employee_level_id = el.id
      e.sprint_id = random + 2*n
      e.effort = [25, 30, 50, 60, 75, 80, 100].sample
    end
  end
end
