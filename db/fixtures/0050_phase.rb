# frozen_string_literal: true

Project.all.each do |project|
  starts_on = Date.today
  3.times do |n|
    Phase.seed do |p|
      p.name = "phase #{n+1}"
      p.project_id = project.id
      p.starts_on = starts_on
      p.ends_on = starts_on + 70.days
      starts_on += 71.days
    end
  end
end
