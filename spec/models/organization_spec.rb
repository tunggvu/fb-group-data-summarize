# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization, type: :model do
  describe "#associations" do
    it { should have_many(:employees) }
  end

  describe "#validates" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:level) }
  end

  describe "#manager_name" do
    let!(:organization) { create(:organization, :division, name: "Division") }
    let(:manager) { create(:employee, organization: organization) }

    before do
      organization.update manager_id: manager.id
    end

    it "should return manager name" do
      expect(organization.manager_name).to eq manager.name
    end
  end

  describe "#full_name" do
    let!(:division) { create(:organization, :division, name: "Division 1") }
    let!(:section) { create(:organization, :section, parent: division, name: "Section 1") }
    let!(:group) { create(:organization, :clan, parent: section, name: "Group 1") }
    let!(:team) { create(:organization, :team, parent: group, name: "Team 1") }

    it "should return divistion's full name" do
      expect(division.full_name).to eq "Division 1"
    end

    it "should return section's full name" do
      expect(section.full_name).to eq "Division 1 / Section 1"
    end

    it "should return group's full name" do
      expect(group.full_name).to eq "Division 1 / Section 1 / Group 1"
    end

    it "should return team's full name" do
      expect(team.full_name).to eq "Division 1 / Section 1 / Group 1 / Team 1"
    end
  end

  describe "#employee_ids" do
    let!(:division) { create(:organization, :division) }
    let!(:section) { create(:organization, :section, parent: division) }
    let!(:group) { create(:organization, :clan, parent: section) }
    let!(:team) { create(:organization, :team, parent: group) }

    let!(:team_member_1) { create :employee, organization: team }
    let!(:team_member_2) { create :employee, organization: team }
    let!(:group_leader) { create :employee, organization: group }
    let!(:section_manager) { create :employee, organization: section }
    let!(:division_manager) { create :employee, organization: division }

    before do
      division.update manager_id: division_manager.id
      section.update manager_id: section_manager.id
      group.update manager_id: group_leader.id
    end

    context "when organization is division" do
      it "should return all id of divistion employee" do
        expect(division.employee_ids.sort).to eq Employee.all.ids
      end
    end

    context "when organization is session" do
      it "should return all id of section employee" do
        expect(section.employee_ids.sort).to eq Employee.where("organization_id IN (?)",
          [section.id, group.id, team.id]).ids
      end
    end

    context "when organization is group" do
      it "should return all id of group employee" do
        expect(group.employee_ids.sort).to eq Employee.where("organization_id IN (?)",
          [group.id, team.id]).ids
      end
    end

    context "when organization is team" do
      it "should return all id of group employee" do
        expect(team.employee_ids.sort).to eq Employee.where("organization_id = ?",
          team.id).ids
      end
    end
  end
end
