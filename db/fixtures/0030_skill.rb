# frozen_string_literal: true

["Ruby", "Java"].each do |language|
  ["Junior", "Midle", "Senior"].each do |level|
    Skill.seed do |s|
      s.name = language
      s.level = level
    end
  end
end
