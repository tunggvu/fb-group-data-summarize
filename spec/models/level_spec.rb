# frozen_string_literal: true

require "rails_helper"

RSpec.describe Level, type: :model do
  describe "#associations" do
    it { should have_many(:requirements) }
    it { should have_many(:employee_levels) }
    it { should have_many(:employees) }
    it { should belong_to(:skill) }
  end

  describe "#validates" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:rank) }
    it { should validate_presence_of(:skill) }
  end
end
