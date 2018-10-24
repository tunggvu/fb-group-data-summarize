# frozen_string_literal: true

require "rails_helper"

RSpec.describe Project, type: :model do
  describe "#associations" do
    it { should have_many(:phases) }
    it { should have_many(:sprints) }
    it { should belong_to(:product_owner) }
    it { should have_many(:efforts).through(:sprints) }
    it { should have_many(:employee_levels).through(:efforts) }
    it { should have_many(:employees).through(:employee_levels) }
  end

  describe "#validates" do
    it { should validate_presence_of(:name) }
  end

  describe "current_sprint" do
    let(:project) { FactoryBot.create :project }

    context "when project does not have sprint" do
      it "should return nil" do
        expect(project.current_sprint).to eq nil
      end
    end

    context "when project does not have current sprint" do
      let!(:sprint) { FactoryBot.create :sprint, project_id: project.id, starts_on: 1.day.from_now, ends_on: 2.days.from_now }
      it "should return nil" do
        expect(project.current_sprint).to eq nil
      end
    end

    context "when project has current sprint" do
      let!(:sprint) { FactoryBot.create :sprint, project_id: project.id, starts_on: Date.today, ends_on: 2.days.from_now }
      it "should return current sprint" do
        expect(project.current_sprint).to eq sprint
      end
    end
  end

  describe "current_phase" do
    let(:project) { FactoryBot.create :project }

    context "when project does not have phase" do
      it "should return nil" do
        expect(project.current_phase).to eq nil
      end
    end

    context "when project does not have current phase" do
      let!(:phase) { FactoryBot.create :phase, project_id: project.id, starts_on: 1.day.from_now, ends_on: 2.days.from_now }
      it "should return nil" do
        expect(project.current_phase).to eq nil
      end
    end

    context "when project has current phase" do
      let!(:phase) { FactoryBot.create :phase, project_id: project.id, starts_on: 3.days.ago, ends_on: 3.days.from_now }
      let!(:sprint) { FactoryBot.create :sprint, project: project, phase: phase, starts_on: 2.days.ago, ends_on: 2.day.from_now }
      it "should return current phase" do
        expect(project.current_phase).to eq phase
      end
    end
  end
end
