# frozen_string_literal: true

require "rails_helper"

RSpec.describe TotalEffort, type: :model do
  describe "#associations" do
    it { should belong_to(:employee) }
  end

  describe "#validates" do
    let!(:total_effort) { FactoryBot.build :total_effort }
    it { should validate_presence_of(:value) }
    it { should validate_numericality_of(:value).only_integer.is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:start_time) }
    it { should validate_presence_of(:end_time) }
    it { expect(total_effort.end_time > total_effort.start_time).to eq true }
  end

  describe "#end_time_must_after_start_time" do
    context "when start time after end time" do
      let(:total_effort) { FactoryBot.build :total_effort, start_time: Time.zone.now, end_time: 3.days.ago }

      it "should be invalid" do
        expect(total_effort).to be_invalid
      end

      it "shoud return error" do
        total_effort.save
        expect(total_effort.errors.full_messages).to include "End time must be after the start time"
        expect(TotalEffort.count).to eq 0
      end
    end

    context "when start time before end time" do
      let(:total_effort) { FactoryBot.build :total_effort, start_time: Time.zone.now, end_time: 3.days.from_now }

      it "should be valid" do
        expect(total_effort).to be_valid
      end

      it "save to DB" do
        total_effort.save
        expect(TotalEffort.count).to eq 1
      end
    end
  end
end
