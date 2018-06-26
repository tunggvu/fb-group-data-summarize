# frozen_string_literal: true

require "rails_helper"

RSpec.describe Division, type: :model do
  describe "#associations" do
    it { should have_many(:sections) }
  end

  describe "#validates" do
    it { should validate_presence_of(:name) }
  end
end
