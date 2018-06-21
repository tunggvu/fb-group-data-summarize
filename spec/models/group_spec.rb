# frozen_string_literal: true

require "rails_helper"

RSpec.describe Group, type: :model do
  describe "#associations" do
    it { should have_many(:teams) }
    it { should belong_to(:section) }
  end

  describe "#validates" do
    it { should validate_presence_of(:name) }
  end
end
