# frozen_string_literal: true

require "rails_helper"

RSpec.describe Sprint, type: :model do
  let(:project) { FactoryBot.create :project }
  let(:phase) { FactoryBot.create :phase, project: project }
  let!(:sprint) { FactoryBot.create :sprint, project: project, phase: phase, starts_on: Date.current, ends_on: 3.days.from_now }
  let!(:sprint1) { FactoryBot.create :sprint, project: project, phase: phase, starts_on: 4.days.from_now, ends_on: 6.days.from_now }
  let!(:sprint2) { FactoryBot.create :sprint, project: project, phase: phase, starts_on: 7.days.from_now, ends_on: 9.days.from_now }

  describe "#associations" do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:phase) }
    it { is_expected.to have_many(:efforts) }
  end

  describe "#validates" do
    subject { FactoryBot.build :sprint, starts_on: Time.zone.now, ends_on: 3.days.from_now }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:starts_on) }
    it { is_expected.to validate_presence_of(:ends_on) }
    it { expect(subject.ends_on > subject.starts_on).to eq true }
  end

  describe "#ends_on_must_after_starts_on" do
    let(:phase) { FactoryBot.create :phase }
    context "when start time after end time" do
      let(:sprint) { FactoryBot.build :sprint, phase: phase, starts_on: Time.zone.now, ends_on: 3.days.ago }

      it "should be invalid" do
        expect(sprint).to be_invalid
      end

      it "shoud return error" do
        sprint.save
        expect(sprint.errors.full_messages).to include "Ends on must be after the starts on"
        expect(Sprint.count).to eq 2
      end
    end

    context "when start time before end time" do
      let(:sprint) { FactoryBot.build :sprint, starts_on: Time.zone.now, ends_on: 3.days.from_now }

      it "should be valid" do
        expect(sprint).to be_valid
      end

      it "save to DB" do
        sprint.save
        expect(Sprint.count).to eq 3
      end
    end
  end

  describe "#validate_starts_on_after_ends_on_previous_sprint" do
    context "when starts on before ends on of previous sprint" do
      it "should return error" do
        sprint1.starts_on = 2.days.from_now
        sprint1.send(:validate_starts_on_after_ends_on_previous_sprint)
        expect(sprint1.errors.full_messages).to include "Starts on must be after ends on previous sprint"
      end
    end

    context "when starts on after ends on of previous sprint" do
      let(:sprint3) { FactoryBot.build :sprint, project: project, phase: phase, starts_on: 10.days.from_now, ends_on: 11.days.from_now }
      it "should return blank error" do
        sprint3.send(:validate_starts_on_after_ends_on_previous_sprint)
        expect(sprint3.errors.full_messages).to eq []
      end
    end
  end

  describe "#validate_ends_on_after_starts_on_next_sprint" do
    context "when ends on before starts on of next sprint" do
      it "should return error" do
        sprint1.ends_on = 7.days.from_now
        sprint1.send(:validate_ends_on_after_starts_on_next_sprint)
        expect(sprint1.errors.full_messages).to include "Ends on must be after starts on next sprint"
      end
    end

    context "when ends on after starts on of next sprint" do
      let(:sprint3) { FactoryBot.build :sprint, project: project, phase: phase, starts_on: 10.days.from_now, ends_on: 11.days.from_now }
      it "should return blank error" do
        sprint3.send(:validate_ends_on_after_starts_on_next_sprint)
        expect(sprint3.errors.full_messages).to eq []
      end
    end
  end

  describe "#previous_sprint" do
    it "return previous sprint" do
      expect(sprint2.previous_sprint).to eq sprint1
    end

    it "return nil" do
      expect(sprint.previous_sprint).to be_nil
    end
  end

  describe "#next_sprint" do
    it "return next sprint" do
      expect(sprint.next_sprint).to eq sprint1
    end

    it "return nil" do
      expect(sprint2.next_sprint).to be_nil
    end
  end

  describe "#validate_time_in_phases" do
    let(:phase) { FactoryBot.create :phase }

    context "starts on before starts on of phase" do
      let(:sprint) { FactoryBot.build :sprint, starts_on: 11.days.ago }

      it "return invalid" do
        expect(sprint).to be_invalid
      end

      it "return erros invalid sprint time" do
        sprint.save
        expect(sprint.errors.full_messages).to include I18n.t("models.sprint.invalid_sprint_time")
      end
    end

    context "end on after ends on of phase" do
      let(:sprint) { FactoryBot.build :sprint, ends_on: 21.days.from_now }

      it "return invalid" do
        expect(sprint).to be_invalid
      end

      it "return erros invalid sprint time" do
        sprint.save
        expect(sprint.errors.full_messages).to include I18n.t("models.sprint.invalid_sprint_time")
      end
    end

    context "starts on after starts on of phase" do
      let(:sprint) { FactoryBot.build :sprint, starts_on: 2.days.ago, ends_on: 9.days.from_now }

      it "return valid" do
        expect(sprint).to be_valid
      end

      it "save to DB" do
        sprint.save
        expect(Sprint.count).to eq 3
      end
    end
  end
end
