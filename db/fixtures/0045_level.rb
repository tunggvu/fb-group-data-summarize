# frozen_string_literal: true

Skill.all.each do |skill|
  ["Junior", "Middle", "Senior"].each_with_index do |level, index|
    Level.seed do |s|
      s.rank = index + 1
      s.name = level
      s.logo = "#"
      s.skill = skill
    end
  end
end
