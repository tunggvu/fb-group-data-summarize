# frozen_string_literal: true

require "rails_helper"

RSpec.describe Request, type: :model do
  describe "#associations" do
    it { should belong_to(:device) }
    it { should belong_to(:project) }
    it { should belong_to(:request_pic) }
    it { should belong_to(:requester) }
  end

  let(:admin) { FactoryBot.create :employee, :admin, organization: nil }
  let(:division) { FactoryBot.create :organization, :division, name: "Division 1" }
  let(:product_owner1) { FactoryBot.create :employee, organization: division }
  let(:product_owner2) { FactoryBot.create :employee, organization: division }
  let(:project1) { FactoryBot.create :project, product_owner: product_owner1 }
  let(:project2) { FactoryBot.create :project, product_owner: product_owner1 }
  let(:project3) { FactoryBot.create :project, product_owner: product_owner2 }
  let(:pic1) { FactoryBot.create :employee, organization: division }
  let(:pic2) { FactoryBot.create :employee, organization: division }
  let(:device1) { FactoryBot.create :device, :laptop, name: "Device 1", project: project1 }
  let(:skill) { FactoryBot.create :skill }
  let(:level) { FactoryBot.create :level, skill: skill }
  let(:employee_level1) { FactoryBot.create :employee_level, employee: pic1, level: level }
  let(:sprint1) { FactoryBot.create :sprint, project: project1, starts_on: project1.starts_on, ends_on: 7.days.from_now }
  let!(:effort1) { FactoryBot.create :effort, sprint: sprint1, employee_level: employee_level1, effort: 80 }
  let(:sprint2) { FactoryBot.create :sprint, project: project2, starts_on: project2.starts_on, ends_on: 7.days.from_now }
  let!(:effort2) { FactoryBot.create :effort, sprint: sprint2, employee_level: employee_level1, effort: 30 }

  before do
    device1.update_attribute :pic, pic1
    device1.requests.create!(request_pic: product_owner1, project: project1, requester: product_owner1, status: :approved)
  end

  describe "#valid_pic?" do
    context "pic belongs to project" do
      let(:request) {
        FactoryBot.build :request, device: device1, project: project1, request_pic: product_owner1, requester: product_owner1
      }

      it "should valid" do
        expect(request).to be_valid
      end
    end

    context "pic doesn't belong to project" do
      let(:request) {
        FactoryBot.build :request, device: device1, project: project1, request_pic: pic2, requester: product_owner1
      }

      it "should invalid" do
        expect(request).to be_invalid
      end
    end
  end

  describe "#change_owner?" do
    context "pic or project changes" do
      let(:request) {
        FactoryBot.build :request, device: device1, project: project1, request_pic: product_owner1, requester: product_owner1
      }

      it "should valid" do
        expect(request).to be_valid
      end
    end

    context "pic and project don't change" do
      let(:request) {
        FactoryBot.build :request, device: device1, project: project1, request_pic: pic1, requester: product_owner1
      }

      it "should invalid" do
        expect(request).to be_invalid
      end
    end
  end

  describe "#can_update_pic?" do
    context "if requester is pic" do
      let(:request1) {
        FactoryBot.build :request, device: device1, project: project1, request_pic: product_owner1, requester: pic1
      }
      let(:request2) {
        FactoryBot.build :request, device: device1, project: project1, request_pic: pic2, requester: pic1
      }

      it "should valid if request_pic belongs to project of device" do
        expect(request1).to be_valid
      end

      it "should invalid if request_pic doesn't belong to project of device" do
        expect(request2).to be_invalid
      end
    end

    context "if requester is product owner" do
      let(:request1) {
        FactoryBot.build :request, device: device1, project: project2, request_pic: pic1, requester: product_owner1
      }
      let(:request2) {
        FactoryBot.build :request, device: device1, project: project3, request_pic: pic1, requester: product_owner1
      }

      it "should valid if request project belongs to product owner" do
        expect(request1).to be_valid
      end

      it "should invalid if request project doesn't belong to product owner" do
        expect(request2).to be_invalid
      end
    end

    context "if requester is admin" do
      let(:request1) {
        FactoryBot.build :request, device: device1, project: project2, request_pic: pic1, requester: admin
      }

      it "should valid if request project belongs to product owner" do
        expect(request1).to be_valid
      end
    end
  end

  describe "aasm" do
    let(:request) { device1.requests.last }
    let(:token) { "token" }

    before do
      request.update confirmation_digest: Request.digest(token)
    end

    context ".approve" do
      before do
        request.update status: :pending
        request.approve!(:approved, token)
      end

      include_examples "null digest"
    end

    context ".confirm" do
      before do
        request.update status: :approved
        request.confirm!(:confirmed, token)
      end

      include_examples "null digest"

      it "should update device pic" do
        expect(request.device.pic).to eq(request.request_pic)
      end
    end

    context ".reject" do
      before do
        request.update status: :approved
        request.reject!(:rejected, token)
      end

      include_examples "null digest"
    end
  end
end
