# frozen_string_literal: true

require "rails_helper"

RSpec.describe Employee, type: :model do
  subject { FactoryBot.create(:employee) }
  describe "#associations" do
    it { should have_many(:employee_levels) }
    it { should have_many(:levels) }
    it { should have_many(:projects_effort) }
    it { should belong_to(:organization) }
  end

  describe "#validates" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).on(:create) }
  end
end
