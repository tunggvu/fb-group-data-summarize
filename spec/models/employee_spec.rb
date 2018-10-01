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

  describe ".with_total_efforts_in_period" do
    let(:division) { FactoryBot.create(:organization, :division, name: "Division 1") }
    let(:employee) { FactoryBot.create :employee, organization: division }
    let(:total_efforts) { FactoryBot.create :total_effort, employee: employee, start_time: 2.days.ago, end_time: 2.days.from_now }

    it "should return array include total effort relate to a period of time" do
      expect(Employee.with_total_efforts_in_period(3.days.ago, 3.days.from_now)).to include employee
    end

    it "should return array include total effort relate to a period of time" do
      expect(Employee.with_total_efforts_in_period(3.days.ago, 1.day.from_now)).to include employee
    end

    it "should return array include total effort relate to a period of time" do
      expect(Employee.with_total_efforts_in_period(1.day.from_now, 3.days.from_now)).to include employee
    end

    it "should return array empty" do
      expect(Employee.with_total_efforts_in_period(15.days.ago, 10.days.ago)).to eq([])
    end
  end

  context ".with_total_efforts_* " do
    let(:division) { FactoryBot.create(:organization, :division, name: "Division 1") }
    let(:employee1) { FactoryBot.create :employee, organization: division }
    let(:employee2) { FactoryBot.create :employee, organization: division }
    let!(:total_effort1) { FactoryBot.create :total_effort, employee: employee1, value: 30, start_time: 2.days.ago, end_time: 2.days.from_now }
    let!(:total_effort2) { FactoryBot.create :total_effort, employee: employee2, value: 90, start_time: 2.days.ago, end_time: 2.days.from_now }

    describe ".with_total_efforts_lt" do
      it "should return array employees that max_total_effort is small than params" do
        expect(Employee.joins(:total_efforts).with_total_efforts_lt(50)).to include employee1
      end

      it "should return array employees that max_total_effort is small than params" do
        expect(Employee.joins(:total_efforts).with_total_efforts_lt(10)).to be_empty
      end

      it "should return array employees that max_total_effort is small than params" do
        expect(Employee.joins(:total_efforts).with_total_efforts_lt(95)).to include employee2, employee1
      end
    end

    describe ".with_total_efforts_gt" do
      it "should return array employees that max_total_effort is greater than 50" do
        expect(Employee.joins(:total_efforts).with_total_efforts_gt(50)).to include employee2
      end

      it "should return array employees that max_total_effort is greater than 110" do
        expect(Employee.joins(:total_efforts).with_total_efforts_gt(110)).to be_empty
      end

      it "should return array employees that max_total_effort is greater than 20" do
        expect(Employee.joins(:total_efforts).with_total_efforts_gt(20)).to include employee2, employee1
      end
    end
  end
end
