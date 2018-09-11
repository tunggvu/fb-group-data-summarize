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

  describe ".relate_to_period" do
    let(:sprint) { FactoryBot.create :sprint, starts_on: 1.day.ago, ends_on: 1.day.from_now }
    let(:effort) { FactoryBot.create :effort, sprint: sprint }
    let(:other_sprint) { FactoryBot.create :sprint, starts_on: 5.days.ago, ends_on: 3.days.ago }
    let(:other_effort) { FactoryBot.create :effort, sprint: other_sprint }
    it "should return array include effort not relate to a period of time" do
      expect(Effort.relate_to_period(2.days.ago, 2.days.from_now)).to include effort
    end

    it "should return array not include effort relate to a period of time" do
      expect(Effort.relate_to_period(2.days.ago, 2.days.from_now)).not_to include other_effort
    end
  end

  describe "#employee_must_be_unique_in_sprint" do
    let(:sprint) { FactoryBot.create :sprint }
    let(:employee) { FactoryBot.create :employee }
    let(:employee_ruby) { FactoryBot.create :employee_level, employee: employee }
    let(:employee_react) { FactoryBot.create :employee_level, employee: employee }

    let!(:effort_of_employee) { FactoryBot.create :effort, sprint: sprint, employee_level: employee_ruby }

    context "add employee with many different skills to sprint" do
      let(:another_effort_of_employee) { FactoryBot.build :effort, sprint: sprint, employee_level: employee_react }

      it "should be invalid" do
        expect(another_effort_of_employee).to be_invalid
      end
    end

    context "add different employees to sprint" do
      let(:effort_of_different_employee) { FactoryBot.build :effort, sprint: sprint }

      it "should be invalid" do
        expect(effort_of_different_employee).to be_valid
      end
    end
  end
end
