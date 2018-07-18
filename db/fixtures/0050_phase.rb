# frozen_string_literal: true

Project.all.each do |project|
  5.times do |n|
    Phase.seed do |p|
      p.name = "phase #{n+1}"
      p.project_id = project.id
    end
  end
end
