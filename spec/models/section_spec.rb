# frozen_string_literal: true

require "rails_helper"

RSpec.describe Section, type: :model do
  describe "#associations" do
    it { should belong_to(:division) }
    it { should have_many(:groups) }
  end

  describe "#validates" do
    it { should validate_presence_of(:name) }
  end
end
