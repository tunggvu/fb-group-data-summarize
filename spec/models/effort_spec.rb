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

  describe "#update_total_efforts_after_create" do
    let(:employee) { FactoryBot.create :employee, :skip_callback }
    let(:employee_level) { FactoryBot.create :employee_level, employee: employee }
    let(:phase) { FactoryBot.create :phase, starts_on: "2018-04-09", ends_on: "2018-12-20" }
    let!(:total_effort) { FactoryBot.create :total_effort, start_time: "2018-09-07",
      end_time: "2018-10-25", value: 50, employee: employee
    }
    context "when end_time equal ends_on of sprint" do
      let(:sprint) { FactoryBot.create :sprint, phase: phase, starts_on: "2018-09-07", ends_on: "2018-10-25" }
      let(:effort) { FactoryBot.build :effort, sprint: sprint, employee_level: employee_level, effort: 50 }
      it "should update value of total_effort" do
        effort.save
        expect(total_effort.reload.value).to eq 100
      end
    end

    context "when time wrap time of sprint" do
      let(:sprint) { FactoryBot.create :sprint, phase: phase, starts_on: "2018-09-10", ends_on: "2018-10-18" }
      let(:effort) { FactoryBot.build :effort, sprint: sprint, employee_level: employee_level, effort: 50 }
      it "should update value of total_effort" do
        effort.save
        expect(total_effort.reload.start_time.to_s).to eq((sprint.starts_on).to_s)
        expect(total_effort.reload.end_time.to_s).to eq((sprint.ends_on).to_s)
        expect(total_effort.reload.value).to eq 100
      end
    end
  end

  describe "#update_total_efforts_after_create" do
    let(:employee) { FactoryBot.create :employee, :skip_callback }
    let(:employee_level) { FactoryBot.create :employee_level, employee: employee }
    let(:phase) { FactoryBot.create :phase, starts_on: "2018-04-09", ends_on: "2018-12-20" }
    let!(:total_effort) { FactoryBot.create :total_effort, start_time: "2018-11-04",
      end_time: "2018-11-20", value: 50, employee: employee
    }
    let!(:total_effort1) { FactoryBot.create :total_effort, start_time: "2018-11-21",
      end_time: "2018-12-12", value: 50, employee: employee
    }
    context "when start_time equal starts_on of sprint" do
      let(:sprint) { FactoryBot.create :sprint, phase: phase, starts_on: "2018-11-04", ends_on: "2018-12-12" }
      let(:effort) { FactoryBot.build :effort, sprint: sprint, effort: 50, employee_level: employee_level }
      it "should update value of total_effort" do
        effort.save
        expect(total_effort.reload.value).to eq 100
        expect(total_effort1.reload.value).to eq 100
      end
    end

    context "when time of total_effort wrap time of sprint" do
      let(:sprint) { FactoryBot.create :sprint, phase: phase, starts_on: "2018-11-10", ends_on: "2018-11-27" }
      let(:effort) { FactoryBot.build :effort, sprint: sprint, effort: 50, employee_level: employee_level }
      it "should update value of total_effort" do
        effort.save
        expect(total_effort.reload.value).to eq 100
        expect(total_effort1.reload.value).to eq 50
      end
    end

    context "when time of total_effort wrap time of sprint and start time of sprint equal total_effort" do
      let(:sprint) { FactoryBot.create :sprint, phase: phase, starts_on: "2018-11-04", ends_on: "2018-11-27" }
      let(:effort) { FactoryBot.build :effort, sprint: sprint, effort: 50, employee_level: employee_level }
      it "should update value of total_effort" do
        effort.save
        expect(total_effort.reload.value).to eq 100
        expect(total_effort1.reload.value).to eq 50
      end

      it "should update time of total effort" do
        effort.save
        expect(total_effort1.reload.start_time).to eq(sprint.ends_on + 1.day)
      end
    end

    context "when time of total_effort wrap time of sprint and end time of sprint equal total_effort" do
      let(:sprint) { FactoryBot.create :sprint, phase: phase, starts_on: "2018-11-10", ends_on: "2018-12-12" }
      let(:effort) { FactoryBot.build :effort, sprint: sprint, effort: 50, employee_level: employee_level }
      it "should update value of total_effort" do
        effort.save
        expect(total_effort.reload.value).to eq 100
        expect(total_effort1.reload.value).to eq 100
      end

      it "should update time of total effort" do
        effort.save
        expect(total_effort.reload.start_time).to eq(sprint.starts_on)
      end
    end
  end

  describe "#update_total_efforts_after_create" do
    let(:employee) { FactoryBot.create :employee, :skip_callback }
    let(:employee_level) { FactoryBot.create :employee_level, employee: employee }
    let(:phase) { FactoryBot.create :phase, starts_on: "2018-04-09", ends_on: "2018-12-30" }
    let!(:total_effort1) { FactoryBot.create :total_effort, start_time: "2018-11-04",
      end_time: "2018-11-20", value: 50, employee: employee
    }
    let!(:total_effort2) { FactoryBot.create :total_effort, start_time: "2018-11-21",
      end_time: "2018-12-12", value: 50, employee: employee
    }
    let!(:total_effort3) { FactoryBot.create :total_effort, start_time: "2018-12-13",
      end_time: "2018-12-22", value: 50, employee: employee
    }

    context "time of sprint wrap 3 total effort" do
      let(:sprint) { FactoryBot.create :sprint, phase: phase, starts_on: "2018-11-04", ends_on: "2018-12-22" }
      let(:effort) { FactoryBot.build :effort, sprint: sprint, effort: 50, employee_level: employee_level }

      it "should update new value" do
        effort.save
        expect(total_effort1.reload.value).to eq 100
        expect(total_effort2.reload.value).to eq 100
        expect(total_effort3.reload.value).to eq 100
      end
    end
  end

  describe "#update_total_efforts_after_update" do
    let(:employee) { FactoryBot.create :employee, :skip_callback }
    let(:phase) { FactoryBot.create :phase, starts_on: "2018-04-09", ends_on: "2018-11-20" }
    let(:employee_level) { FactoryBot.create :employee_level, employee: employee }
    let(:sprint) { FactoryBot.create :sprint, phase: phase, starts_on: "2018-09-07", ends_on: "2018-10-25" }
    let!(:total_effort) { FactoryBot.create :total_effort, start_time: "2018-09-07",
      end_time: "2018-10-25", value: 100, employee: employee
    }
    let!(:effort) { FactoryBot.create :effort, sprint: sprint, employee_level: employee_level, effort: 50 }

    context "when update effort" do
      it "should execute update total_effort after update" do
        expect(effort).to receive(:update_total_efforts_after_update)
        effort.update_attributes effort: 80
      end

      it "should update total effort" do
        effort.update_attributes effort: 80
        expect(total_effort.reload.value).to eq 180
      end
    end
  end

  describe "#update_total_efforts_after_delete" do
    let(:employee) { FactoryBot.create :employee, :skip_callback }
    let(:phase) { FactoryBot.create :phase, starts_on: "2018-04-09", ends_on: "2018-11-20" }
    let(:employee_level) { FactoryBot.create :employee_level, employee: employee }
    let(:sprint) { FactoryBot.create :sprint, phase: phase, starts_on: "2018-09-07", ends_on: "2018-10-25" }
    let!(:effort) { FactoryBot.create :effort, sprint: sprint, employee_level: employee_level, effort: 50 }
    let!(:total_effort) { FactoryBot.create :total_effort, start_time: "2018-09-07",
      end_time: "2018-10-25", value: 100, employee: employee
    }
    context "when delete effort" do
      it "should execute update total_effort after delete" do
        expect(effort).to receive(:update_total_efforts_after_delete)
        effort.destroy
      end

      it "should update total effort" do
        effort.destroy
        expect(total_effort.reload.value).to eq 50
      end
    end
  end
end
