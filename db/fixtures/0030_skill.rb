# frozen_string_literal: true

["Ruby", "Java"].each do |language|
  Skill.seed do |s|
    s.name = language
  end
end
