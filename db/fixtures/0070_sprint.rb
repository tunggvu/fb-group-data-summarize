# frozen_string_literal: true

Project.all.each do |project|
  project.phases.each do |phase|
    start_date = phase.starts_on
    5.times do |n|
      Sprint.seed do |sprint|
        sprint.name = "sprint #{n+1}"
        sprint.project_id = project.id
        sprint.phase_id = phase.id
        sprint.starts_on = start_date
        sprint.ends_on = start_date + 2.days
        start_date += 3.days
      end
    end
  end
end
