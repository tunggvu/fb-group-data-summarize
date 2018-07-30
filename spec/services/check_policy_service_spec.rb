# frozen_string_literal: true

require "rails_helper"

RSpec.describe CheckPolicyService do
  describe "#can_manage_employee_for?" do
    let(:division) { FactoryBot.create(:organization, :division, name: "Division 1") }
    let(:section) { FactoryBot.create(:organization, :section, name: "Section 1", parent_id: division.id) }
    let(:clan) { FactoryBot.create(:organization, :clan, name: "Clan 1", parent_id: section.id) }
    let(:team) { FactoryBot.create(:organization, :team, name: "Team 1", parent_id: clan.id) }

    let(:section2) { FactoryBot.create(:organization, :section, name: "Team 1", parent_id: division.id) }
    let(:clan2) { FactoryBot.create(:organization, :clan, name: "Team 1", parent_id: section2.id) }
    let(:team2) { FactoryBot.create(:organization, :team, name: "Team 1", parent_id: clan2.id) }

    let(:section2_manager) { FactoryBot.create :employee, organization: section2 }
    let(:div_manager) { FactoryBot.create :employee, organization: division }

    before do
      division.update(manager_id: div_manager.id)
      section2.update(manager_id: section2_manager.id)
    end

    it { expect(CheckPolicyService.new(user: div_manager).can_manage_employee_for? division).to eq true }
    it { expect(CheckPolicyService.new(user: div_manager).can_manage_employee_for? section).to eq true }
    it { expect(CheckPolicyService.new(user: div_manager).can_manage_employee_for? section).to eq true }
    it { expect(CheckPolicyService.new(user: div_manager).can_manage_employee_for? clan).to eq true }
    it { expect(CheckPolicyService.new(user: div_manager).can_manage_employee_for? team).to eq true }
    it { expect(CheckPolicyService.new(user: div_manager).can_manage_employee_for? team).to eq true }
    it { expect(CheckPolicyService.new(user: div_manager).can_manage_employee_for? section).to eq true }
    it { expect(CheckPolicyService.new(user: section2_manager).can_manage_employee_for? section).to eq false }
    it { expect(CheckPolicyService.new(user: section2_manager).can_manage_employee_for? clan).to eq false }

    it { expect(CheckPolicyService.new(user: div_manager).can_manage_employee_for? section2).to eq true }
    it { expect(CheckPolicyService.new(user: section2_manager).can_manage_employee_for? section2).to eq true }
    it { expect(CheckPolicyService.new(user: section2_manager).can_manage_employee_for? clan).to eq false }
    it { expect(CheckPolicyService.new(user: section2_manager).can_manage_employee_for? team).to eq false }
    it { expect(CheckPolicyService.new(user: section2_manager).can_manage_employee_for? team).to eq false }
    it { expect(CheckPolicyService.new(user: section2_manager).can_manage_employee_for? clan2).to eq true }
  end

  describe "#can_manage_organization?" do
    let(:division) { FactoryBot.create(:organization, :division, name: "Division 1") }
    let(:section) { FactoryBot.create(:organization, :section, name: "Section 1", parent_id: division.id) }
    let(:clan) { FactoryBot.create(:organization, :clan, name: "Clan 1", parent_id: section.id) }
    let(:team) { FactoryBot.create(:organization, :team, name: "Team 1", parent_id: clan.id) }

    let(:section2) { FactoryBot.create(:organization, :section, name: "Team 1", parent_id: division.id) }
    let(:clan2) { FactoryBot.create(:organization, :clan, name: "Team 1", parent_id: section2.id) }
    let(:team2) { FactoryBot.create(:organization, :team, name: "Team 1", parent_id: clan2.id) }

    let(:section2_manager) { FactoryBot.create :employee, organization: section2 }
    let(:div_manager) { FactoryBot.create :employee, organization: division }

    before do
      division.update(manager_id: div_manager.id)
      section2.update(manager_id: section2_manager.id)
    end

    it { expect(CheckPolicyService.new(user: div_manager).can_manage_organization? division).to eq true }
    it { expect(CheckPolicyService.new(user: div_manager).can_manage_organization? section).to eq true }
    it { expect(CheckPolicyService.new(user: div_manager).can_manage_organization? section).to eq true }
    it { expect(CheckPolicyService.new(user: div_manager).can_manage_organization? clan).to eq true }
    it { expect(CheckPolicyService.new(user: div_manager).can_manage_organization? team).to eq true }
    it { expect(CheckPolicyService.new(user: div_manager).can_manage_organization? team).to eq true }
    it { expect(CheckPolicyService.new(user: div_manager).can_manage_organization? section).to eq true }
    it { expect(CheckPolicyService.new(user: section2_manager).can_manage_organization? section).to eq false }
    it { expect(CheckPolicyService.new(user: section2_manager).can_manage_organization? clan).to eq false }

    it { expect(CheckPolicyService.new(user: div_manager).can_manage_organization? section2).to eq true }
    it { expect(CheckPolicyService.new(user: section2_manager).can_manage_organization? section2).to eq true }
    it { expect(CheckPolicyService.new(user: section2_manager).can_manage_organization? clan).to eq false }
    it { expect(CheckPolicyService.new(user: section2_manager).can_manage_organization? team).to eq false }
    it { expect(CheckPolicyService.new(user: section2_manager).can_manage_organization? team).to eq false }
    it { expect(CheckPolicyService.new(user: section2_manager).can_manage_organization? clan2).to eq true }
  end

  describe "#can_manage_project?" do
    let(:division) { FactoryBot.create(:organization, :division, name: "Division 1") }
    let(:section) { FactoryBot.create(:organization, :section, name: "Section 1", parent_id: division.id) }
    let(:clan) { FactoryBot.create(:organization, :clan, name: "Clan 1", parent_id: section.id) }
    let(:team) { FactoryBot.create(:organization, :team, name: "Team 1", parent_id: clan.id) }
    let(:section2) { FactoryBot.create(:organization, :section, name: "Team 1", parent_id: division.id) }
    let(:clan2) { FactoryBot.create(:organization, :clan, name: "Team 1", parent_id: section2.id) }
    let(:team2) { FactoryBot.create(:organization, :team, name: "Team 1", parent_id: clan2.id) }

    let(:section2_manager) { FactoryBot.create :employee, organization: section2 }
    let(:div_manager) { FactoryBot.create :employee, organization: division }
    let(:section_manager) { FactoryBot.create :employee, organization: section }
    let(:clan_manager) { FactoryBot.create :employee, organization: clan }

    let!(:project) { FactoryBot.create(:project, product_owner: div_manager) }
    let!(:another_project) { FactoryBot.create(:project, product_owner: section2_manager) }
    let!(:project2) { FactoryBot.create(:project, product_owner: clan_manager) }

    before do
      division.update(manager_id: div_manager.id)
      section2.update(manager_id: section2_manager.id)
      section.update(manager_id: section_manager.id)
      clan.update(manager_id: clan_manager.id)
    end

    it { expect(CheckPolicyService.new(user: section2_manager).can_manage_project? another_project).to eq true }
    it { expect(CheckPolicyService.new(user: div_manager).can_manage_project? project).to eq true }
    it { expect(CheckPolicyService.new(user: div_manager).can_manage_project? another_project).to eq true }
    it { expect(CheckPolicyService.new(user: section2_manager).can_manage_project? project).to eq false }
    it { expect(CheckPolicyService.new(user: section_manager).can_manage_project? another_project).to eq false }
    it { expect(CheckPolicyService.new(user: section_manager).can_manage_project? project2).to eq true }
    it { expect(CheckPolicyService.new(user: div_manager).can_manage_project? project2).to eq true }
    it { expect(CheckPolicyService.new(user: section2_manager).can_manage_project? project2).to eq false }
  end
end
