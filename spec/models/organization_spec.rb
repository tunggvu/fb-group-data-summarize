# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization, type: :model do
  describe "#associations" do
    it { should have_many(:employees) }
    it { should have_many(:children) }
    it { should belong_to(:parent) }
  end

  describe "#validates" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:manager_id) }
    it { should validate_presence_of(:level) }
  end
end
