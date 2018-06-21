# frozen_string_literal: true

require "rails_helper"

RSpec.describe Project, type: :model do
  describe "#associations" do
    it { should have_many(:phases) }
    it { should have_many(:sprints) }
  end

  describe "#validates" do
    it { should validate_presence_of(:name) }
  end
end
