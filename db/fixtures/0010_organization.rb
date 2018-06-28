# frozen_string_literal: true

Organization.seed do |o|
  o.id = 1
  o.name = "Division 1"
  o.level = "division"
  o.manager_id = 2
end

Organization.seed do |o|
  o.id = 2
  o.name = "Section 1"
  o.level = "section"
  o.manager_id = 3
  o.parent_id = 1
end

Organization.seed do |o|
  o.id = 3
  o.name = "Group 1"
  o.level = "clan"
  o.manager_id = 4
  o.parent_id = 2
end

Organization.seed do |o|
  o.id = 4
  o.name = "Team 1"
  o.level = "team"
  o.manager_id = 5
  o.parent_id = 3
end
