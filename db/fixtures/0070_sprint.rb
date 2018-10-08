# frozen_string_literal: true

Project.all.each do |project|
  project.phases.each do |phase|
    start_date = phase.starts_on
    5.times do |n|
      Sprint.seed do |sprint|
        end_date = start_date + [1, 2].sample.weeks
        sprint.name = "sprint #{n+1}"
        sprint.project_id = project.id
        sprint.phase_id = phase.id
        sprint.starts_on = start_date
        sprint.ends_on = end_date
        start_date = end_date.tomorrow
      end
    end
  end
end
