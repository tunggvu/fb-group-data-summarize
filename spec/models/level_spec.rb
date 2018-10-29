# frozen_string_literal: true

require "rails_helper"

RSpec.describe Level, type: :model do
  describe "#associations" do
    it { should have_many(:requirements) }
    it { should have_many(:employee_levels) }
    it { should have_many(:employees) }
    it { should belong_to(:skill) }
  end

  describe "#validates" do
    let(:skill) { FactoryBot.create :skill }
    let!(:level) { FactoryBot.create :level, skill: skill }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).scoped_to(:skill_id) }
    it { should validate_presence_of(:rank) }
    it { should validate_presence_of(:skill) }
  end

  describe ".levels_by_employee" do
    let(:division) { FactoryBot.create(:organization, :division, name: "Division 1") }
    let(:employee) { FactoryBot.create :employee, organization: division }
    let(:employee2) { FactoryBot.create :employee, organization: division }
    let(:skill) { FactoryBot.create :skill }
    let(:level) { FactoryBot.create :level, skill: skill }
    let(:employee_level) { FactoryBot.create :employee_level, employee: employee, level: level }

    it "should return list levels of this employee for this skill" do
      expect(Level.levels_by_employee(employee.id, skill.id)).to eq employee.levels
    end

    it "should return empty level of this employee" do
      expect(Level.levels_by_employee(employee2.id, skill.id)).to eq []
    end
  end
end
