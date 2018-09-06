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

  describe ".find_by_employee_id" do
    let(:employee) { FactoryBot.create :employee }
    let(:employee_level) { FactoryBot.create :employee_level, employee: employee }
    let(:effort) { FactoryBot.create :effort, employee_level: employee_level }
    let(:other_effort) { FactoryBot.create :effort }
    it "should return array include effort of a employee" do
      expect(Effort.find_by_employee_id(employee.id)).to include effort
    end

    it "should return array not include effort of other employee" do
      expect(Effort.find_by_employee_id(employee.id)).not_to include other_effort
    end
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
end
