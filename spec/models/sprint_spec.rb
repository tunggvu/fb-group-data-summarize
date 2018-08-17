# frozen_string_literal: true

require "rails_helper"

RSpec.describe Sprint, type: :model do
  describe "#associations" do
    it { should belong_to(:project) }
    it { should belong_to(:phase) }
    it { should have_many(:efforts) }
  end

  describe "#validates" do
    let!(:sprint) { FactoryBot.create :sprint }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:starts_on) }
    it { should validate_presence_of(:ends_on) }
    it { expect(sprint.ends_on > sprint.starts_on).to eq true }
  end

  describe "#ends_on_must_after_starts_on" do
    context "when start time after end time" do
      let(:sprint) { FactoryBot.build :sprint, starts_on: Time.zone.now, ends_on: 3.days.ago }

      it "should be invalid" do
        expect(sprint).to be_invalid
      end

      it "shoud return error" do
        sprint.save
        expect(sprint.errors.full_messages).to include "Ends on must be after the starts on"
        expect(Sprint.count).to eq 0
      end
    end

    context "when start time before end time" do
      let(:sprint) { FactoryBot.build :sprint, starts_on: Time.zone.now, ends_on: 3.days.from_now }

      it "should be valid" do
        expect(sprint).to be_valid
      end

      it "save to DB" do
        sprint.save
        expect(Sprint.count).to eq 1
      end
    end
  end
end
