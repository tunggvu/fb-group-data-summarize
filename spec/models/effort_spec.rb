# frozen_string_literal: true

require "rails_helper"

RSpec.describe Effort, type: :model do
  describe "#associations" do
    it { should belong_to(:sprint) }
    it { should belong_to(:employee_skill) }
  end

  describe "#validates" do
    it { should validate_presence_of(:effort) }
  end
end
