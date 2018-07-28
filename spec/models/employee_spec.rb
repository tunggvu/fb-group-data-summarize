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

  describe "#is_higher_role_manager_of?" do
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

    it { expect(div_manager.is_higher_division_manager_of? division).to eq true }
    it { expect(div_manager.is_higher_division_manager_of? section).to eq true }
    it { expect(div_manager.is_higher_section_manager_of? section).to eq true }
    it { expect(div_manager.is_higher_clan_manager_of? clan).to eq true }
    it { expect(div_manager.is_higher_team_manager_of? team).to eq true }
    it { expect(div_manager.is_higher_section_manager_of? team).to eq true }
    it { expect(div_manager.is_higher_clan_manager_of? section).to eq false }
    it { expect(section2_manager.is_higher_division_manager_of? section).to eq false }
    it { expect(section2_manager.is_higher_division_manager_of? clan).to eq false }

    it { expect(div_manager.is_higher_team_manager_of? section2).to eq false }
    it { expect(section2_manager.is_higher_team_manager_of? section2).to eq false }
    it { expect(section2_manager.is_higher_team_manager_of? clan).to eq false }
    it { expect(section2_manager.is_higher_team_manager_of? team).to eq false }
    it { expect(section2_manager.is_higher_division_manager_of? section2).to eq false }
    it { expect(section2_manager.is_higher_division_manager_of? team).to eq false }
    it { expect(section2_manager.is_higher_division_manager_of? clan2).to eq false }
  end
end
