# frozen_string_literal: true

Employee.all.each do |employee|
  Skill.all.each do |skill|
    EmployeeLevel.seed do |el|
      el.employee_id = employee.id
      el.level_id = skill.level_ids.sample
    end
  end
end
