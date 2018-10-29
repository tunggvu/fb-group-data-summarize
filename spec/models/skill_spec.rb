# frozen_string_literal: true

require "rails_helper"

RSpec.describe Skill, type: :model do
  describe "#associations" do
    it { should have_many(:levels) }
  end

  describe "#validates" do
    let!(:skill) { FactoryBot.create :skill }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end
end
