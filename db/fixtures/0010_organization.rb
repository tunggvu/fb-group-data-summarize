# frozen_string_literal: true

def generate_organizations(parent, level, loop_time = 3)
  loop_time.times do |i|
    Organization.seed do |o|
      o.name = "#{Organization.levels.keys[level-1].capitalize} #{i+1}"
      o.level = level
      o.parent = parent
      o.logo = "#"
    end
    generate_organizations(Organization.last, level - 1) unless level == 1
  end
end

generate_organizations(nil, 4)
