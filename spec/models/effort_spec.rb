# frozen_string_literal: true

require "rails_helper"

RSpec.describe Effort, type: :model do
  describe "#associations" do
    it { should belong_to(:sprint) }
    it { should belong_to(:employee_level) }
  end

  describe "#validates" do
    it { should validate_presence_of(:effort) }
    it { should validate_numericality_of(:effort).is_greater_than_or_equal_to 0 }
    it { should validate_numericality_of(:effort).is_less_than_or_equal_to 100 }
    it { should validate_numericality_of(:effort).only_integer }
  end
end
