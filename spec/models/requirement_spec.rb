# frozen_string_literal: true

require "rails_helper"

RSpec.describe Requirement, type: :model do
  describe "#associations" do
    it { should belong_to(:level) }
    it { should belong_to(:phase) }
  end

  describe "#validates" do
    let!(:requirement) { FactoryBot.create :requirement }
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).only_integer }
    it { should validate_numericality_of(:quantity).is_greater_than 0 }
    it { should validate_uniqueness_of(:level_id).scoped_to(:phase_id) }
  end
end
