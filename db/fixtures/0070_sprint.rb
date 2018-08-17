# frozen_string_literal: true

Project.all.each do |project|
  project.phases.each do |phase|
    5.times do |n|
      Sprint.seed do |sprint|
        sprint.name = "sprint #{n+1}"
        sprint.project_id = project.id
        sprint.phase_id = phase.id
        sprint.starts_on = (2*n-1).days.from_now
        sprint.ends_on = (2*n+1).days.from_now
      end
    end
  end
end
