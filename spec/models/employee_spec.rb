# frozen_string_literal: true

require "rails_helper"

RSpec.describe Employee, type: :model do
  describe "#associations" do
    it { should have_many(:employee_skills) }
    it { should have_many(:employee_roles) }
    it { should have_many(:skills) }
    it { should have_many(:roles) }
    it { should belong_to(:organization) }
  end

  describe "#validates" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:employee_code) }
    it { should validate_presence_of(:email) }
  end
end
