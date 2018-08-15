# frozen_string_literal: true

require "rails_helper"

RSpec.describe Employee, type: :model do
  subject { FactoryBot.create(:employee) }
  describe "#associations" do
    it { should have_many(:employee_levels) }
    it { should have_many(:levels) }
    it { should have_many(:projects) }
    it { should belong_to(:organization) }
  end

  describe "#validates" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:employee_code) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).on(:create) }
  end

  describe ".of_organizations" do
    let(:division) { FactoryBot.create(:organization, :division, name: "Division 1") }
    let(:division2) { FactoryBot.create(:organization, :division, name: "Division 2") }
    let(:employee1) { FactoryBot.create :employee, organization: division }
    let(:employee2) { FactoryBot.create :employee, organization: division2 }

    it "should return array include employee of organization" do
      expect(Employee.of_organizations([division.id])).to include(employee1)
    end

    it "should return array not include employee of other oraganization" do
      expect(Employee.of_organizations([division.id])).not_to include(employee2)
    end
  end
end
