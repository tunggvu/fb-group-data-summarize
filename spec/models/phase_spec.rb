# frozen_string_literal: true

require "rails_helper"

RSpec.describe Phase, type: :model do
  describe "#associations" do
    it { should have_many(:sprints) }
    it { should have_many(:requirements) }
  end

  describe "#validates" do
    it { should validate_presence_of(:name) }
  end

  describe "#sprints" do
    let(:phase) { FactoryBot.create(:phase) }
    let(:sprint1) { FactoryBot.create(:sprint, phase: phase, starts_on: 1.day.ago) }
    let(:sprint2) { FactoryBot.create(:sprint, phase: phase) }
    let(:sprint3) { FactoryBot.create(:sprint, phase: phase, starts_on: 1.day.from_now) }

    it "should return sprints sorted by start time descending" do
      expected = [sprint3, sprint2, sprint1]
      expect(phase.sprints).to eq expected
    end
  end
end
