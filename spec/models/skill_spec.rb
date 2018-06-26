# frozen_string_literal: true

require "rails_helper"

RSpec.describe Skill, type: :model do
  describe "#associations" do
    it { should have_many(:employee_skills) }
    it { should have_many(:requirements) }
    it { should have_many(:employees) }
  end

  describe "#validates" do
    it { should validate_presence_of(:name) }
  end
end
