# frozen_string_literal: true

EmployeeLevel.all.each do |el|
  10.times do |n|
    Effort.seed do |e|
      e.employee_level_id = el.id
      e.sprint_id = Faker::Number.between(1, Sprint.all.size)
      e.effort = [25, 30, 50, 60, 75, 80, 100].sample
    end
  end
end
