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
    it { should validate_presence_of(:start_time) }
    it { should validate_presence_of(:end_time) }
    it { expect(sprint.end_time > sprint.start_time).to eq true }
  end

  describe "#validate_end_time_after_start_time" do
    let(:sprint) { FactoryBot.build :sprint, start_time: Time.zone.now, end_time: 10.days.ago }
    it "should be invalid" do
      expect(sprint).to be_invalid
    end
    it "should be return error" do
      sprint.save
      expect(sprint.errors.full_messages).to include "End time must be after the start time"
    end
  end
end
