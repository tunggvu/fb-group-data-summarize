# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmployeeLevel, type: :model do
  describe "#associations" do
    it { should belong_to(:level) }
    it { should belong_to(:employee) }
    it { should have_many(:efforts) }
  end

  describe ".find_by_employee_and_level" do
    let(:level) { FactoryBot.create(:level) }
    let(:employee1) { FactoryBot.create(:employee) }
    let(:employee2) { FactoryBot.create(:employee) }
    let(:employee_level1) { FactoryBot.create :employee_level, employee: employee1, level: level }
    let(:employee_level2) { FactoryBot.create :employee_level, employee: employee2, level: level }
    let(:arr) { [{ employee_id: employee1.id, level_id: level.id }] }

    it "should return array include employee_level of employee with a specific level" do
      expect(EmployeeLevel.find_by_employee_and_level(arr)).to include(employee_level1)
    end

    it "should return array not include employee_level of other employee with a specific level" do
      expect(EmployeeLevel.find_by_employee_and_level(arr)).not_to include(employee_level2)
    end
  end
end
