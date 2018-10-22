# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization, type: :model do
  let!(:division) { FactoryBot.create(:organization, :division, name: "Division 1") }
  let!(:section) { FactoryBot.create(:organization, :section, parent: division, name: "Section 1") }
  let!(:group) { FactoryBot.create(:organization, :clan, parent: section, name: "Group 1") }
  let!(:team) { FactoryBot.create(:organization, :team, parent: group, name: "Team 1") }

  describe "#associations" do
    it { should have_many(:employees) }
  end

  describe "#validates" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:level) }
  end

  describe "#full_name" do


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
    let!(:team_member_1) { FactoryBot.create :employee, organization: team }
    let!(:team_member_2) { FactoryBot.create :employee, organization: team }
    let!(:group_leader) { FactoryBot.create :employee, organization: group }
    let!(:section_manager) { FactoryBot.create :employee, organization: section }
    let!(:division_manager) { FactoryBot.create :employee, organization: division }

    before do
      division.update manager_id: division_manager.id
      section.update manager_id: section_manager.id
      group.update manager_id: group_leader.id
    end

    context "when organization is division" do
      it "should return all id of divistion employee" do
        expect(division.employee_ids).to match_array Employee.all.ids
      end
    end

    context "when organization is section" do
      it "should return all id of section employee" do
        expect(section.employee_ids).to match_array Employee.where("organization_id IN (?)",
          [section.id, group.id, team.id]).ids
      end
    end

    context "when organization is group" do
      it "should return all id of group employee" do
        expect(group.employee_ids).to match_array Employee.where("organization_id IN (?)",
          [group.id, team.id]).ids
      end
    end

    context "when organization is team" do
      it "should return all id of group employee" do
        expect(team.employee_ids).to match_array Employee.where("organization_id = ?",
          team.id).ids
      end
    end
  end

  context "Name in organization has already been taken" do
    let(:invalid_organization) { FactoryBot.build :organization, :section, parent: division, name: "Section 1" }

    it "should be invalid" do
      expect(invalid_organization).to be_invalid
    end

    it "shoud return error" do
      invalid_organization.save
      expect(invalid_organization.errors.full_messages).to include "Name has already been taken"
      expect(Organization.count).to eq 4
    end
  end
end
