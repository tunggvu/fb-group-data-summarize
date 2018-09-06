# frozen_string_literal: true

require "rails_helper"

RSpec.describe Phase, type: :model do
  describe "#associations" do
    it { should have_many(:sprints) }
    it { should have_many(:requirements) }
    it { should validate_presence_of(:starts_on) }
    it { should validate_presence_of(:ends_on) }
  end

  describe "#validates" do
    it { should validate_presence_of(:name) }
  end

  describe "#sprints" do
    let(:phase) { FactoryBot.create(:phase) }
    let(:sprint1) { FactoryBot.create :sprint, phase: phase, starts_on: 10.days.ago, ends_on: 9.days.ago }
    let(:sprint2) { FactoryBot.create :sprint, phase: phase }
    let(:sprint3) { FactoryBot.create :sprint, phase: phase, starts_on: 11.days.from_now, ends_on: 12.days.from_now }

    it "should return sprints sorted by start time descending" do
      expected = [sprint3, sprint2, sprint1]
      expect(phase.sprints).to eq expected
    end
  end

  describe "#ends_on_must_after_starts_on" do
    context "when start time after end time" do
      let(:phase) { FactoryBot.build :phase, starts_on: Time.zone.now, ends_on: 3.days.ago }
      it "should be invalid" do
        expect(phase).to be_invalid
      end

      it "shoud return error" do
        phase.save
        expect(phase.errors.full_messages).to include "Ends on must be after the starts on"
        expect(Phase.count).to eq 0
      end
    end

    context "when start time before end time" do
      let(:phase) { FactoryBot.build :phase, starts_on: Time.zone.now, ends_on: 3.days.from_now }
      it "should be valid" do
        expect(phase).to be_valid
      end

      it "save to DB" do
        phase.save
        expect(Phase.count).to eq 1
      end
    end
  end
end
