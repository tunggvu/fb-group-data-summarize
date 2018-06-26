# frozen_string_literal: true

require "rails_helper"

RSpec.describe Sprint, type: :model do
  describe "#associations" do
    it { should belong_to(:project) }
    it { should belong_to(:phase) }
    it { should have_many(:efforts) }
  end

  describe "#validates" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:start_time) }
    it { should validate_presence_of(:end_time) }
  end
end
