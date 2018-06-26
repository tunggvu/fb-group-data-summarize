# frozen_string_literal: true

require "rails_helper"

RSpec.describe Phase, type: :model do
  describe "#associations" do
    it { should have_many(:sprints) }
    it { should have_many(:requirements) }
  end

  describe "#validates" do
    it { should validate_presence_of(:name) }
  end
end
