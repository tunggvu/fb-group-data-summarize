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

  describe "#role" do
    let(:division) { FactoryBot.create(:organization, :division, name: "Division 1") }
    let(:section) { FactoryBot.create(:organization, :section, name: "Section 1") }
    let(:employee1) { FactoryBot.create :employee, organization: division }
    let(:employee2) { FactoryBot.create :employee, organization: section }

    before do
      division.update_attributes(manager: employee1)
      section.update_attributes(manager: employee2)
    end

    it "should return 'DIVISION_MANAGER'" do
      expect(employee1.role).to eq("DIVISION_MANAGER")
    end

    it "should return 'SECTION_MANAGER'" do
      expect(employee2.role).to eq("SECTION_MANAGER")
    end
  end

  describe ".projects" do
    let(:section) { FactoryBot.create :organization, :section }
    let(:group) { FactoryBot.create :organization, :clan, parent: section }

    let(:employee) { FactoryBot.create :employee }
    let(:group_leader) { FactoryBot.create :employee, organization: group }

    let(:sprint_1) { FactoryBot.create :sprint, project: project_1, phase: phase_1 }
    let(:employee_level_1) { FactoryBot.create :employee_level, employee: employee }
    let(:phase_1) { FactoryBot.create :phase, project: project_1 }


    let!(:project_1) { FactoryBot.create :project }
    let!(:project_2) { FactoryBot.create :project, product_owner: employee }
    let!(:project_3) { FactoryBot.create :project, product_owner: group_leader }

    let!(:effort_employee) { FactoryBot.create :effort, employee_level: employee_level_1, sprint: sprint_1 }

    it "return our project and owned projects" do
      expect(employee.projects).to include(project_1, project_2)
    end
  end

  describe ".owned_projects" do
    let(:employee) { FactoryBot.create :employee }
    let(:admin) { FactoryBot.create :employee, :admin }
    let(:owned_project) { FactoryBot.create :project, product_owner: employee }
    let(:other_project) { FactoryBot.create :project }

    it "return only project that employee is product owner" do
      expect(employee.owned_projects).to eq [owned_project]
    end

    it "return all project if employee is admin" do
      expect(admin.owned_projects).to eq [owned_project, other_project]
    end
  end

  describe ".owned_organizations" do
    let(:employee) { FactoryBot.create :employee, organization: nil }
    let(:admin) { FactoryBot.create :employee, :admin, organization: nil }
    let!(:owned_organization) { FactoryBot.create :organization, manager: employee }
    let!(:other_organization) { FactoryBot.create :organization }

    it "return organization and sub organization that employee is manager" do
      expect(employee.owned_organizations).to eq [owned_organization]
    end

    it "return all organization if employee is admin" do
      expect(admin.owned_organizations).to eq [owned_organization, other_organization]
    end
  end
end
