# frozen_string_literal: true

require "rails_helper"

RSpec.describe Project, type: :model do
  describe "#associations" do
    it { should have_many(:phases) }
    it { should have_many(:sprints) }
    it { should belong_to(:product_owner) }
    it { should have_many(:efforts).through(:sprints) }
    it { should have_many(:employee_levels).through(:efforts) }
    it { should have_many(:employees).through(:employee_levels) }
  end

  describe "#validates" do
    it { should validate_presence_of(:name) }
  end
end
