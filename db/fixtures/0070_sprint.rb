# frozen_string_literal: true

Project.all.each do |project|
  project.phases.each do |phase|
    5.times do |n|
      Sprint.seed do |sprint|
        sprint.name = "sprint #{n+1}"
        sprint.project_id = project.id
        sprint.phase_id = phase.id
        sprint.start_time = Time.zone.now
        sprint.end_time = 10.days.from_now
      end
    end
  end
end
