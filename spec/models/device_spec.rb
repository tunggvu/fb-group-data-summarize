# frozen_string_literal: true

require "rails_helper"

RSpec.describe Device, type: :model do
  describe "#associations" do
    it { should have_many(:requests) }
    it { should belong_to(:project) }
    it { should belong_to(:pic) }
  end

  describe "#validate" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:serial_code) }
    it { should validate_presence_of(:device_type) }
    it { should validate_presence_of(:project_id) }
  end

  let(:division) { FactoryBot.create :organization, :division, name: "Division 1" }
  let(:product_owner) { FactoryBot.create :employee, organization: division }
  let(:project) { FactoryBot.create :project, product_owner: product_owner }
  let(:device) { FactoryBot.create :device, :laptop, name: "Device", pic: product_owner, project: project }

  describe "#assign_to_po" do
    context "when create a device" do
      it "should assign pic for product owner" do
        expect(device.pic_id).to eq product_owner.id
      end
    end
  end

  describe "#create_first_request" do
    context "when create a device" do
      it "should create the first request" do
        expect(device.requests.size).to eq 1

        first_request = device.requests.first
        expect(first_request.requester_id).to eq product_owner.id
        expect(first_request.request_pic_id).to eq product_owner.id
        expect(first_request.project_id).to eq project.id
        expect(first_request.status).to eq "confirmed"
      end
    end
  end
end
