# frozen_string_literal: true

require "rails_helper"

RSpec.describe Team, type: :model do
  describe "#associations" do
    it { should belong_to(:group) }
    it { should have_many(:employees) }
  end

  describe "#validates" do
    it { should validate_presence_of(:name) }
  end
end
