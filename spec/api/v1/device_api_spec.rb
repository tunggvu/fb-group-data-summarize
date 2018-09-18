# frozen_string_literal: true

require "swagger_helper"

describe "Device API" do
  let(:division) { create(:organization, :division, name: "Division 1") }
  let(:section) { create(:organization, :section, parent: division) }
  let(:employee) { create :employee, organization: section }
  let(:product_owner1) { create :employee, organization: division }
  let(:product_owner2) { create :employee, organization: division }
  let(:employee_token) { create :employee_token, employee: employee }
  let(:project1) { create :project, product_owner: product_owner1 }
  let(:project2) { create :project, product_owner: product_owner2 }
  let!(:device1) { create(:device, :laptop, pic: product_owner1, project: project1) }
  let!(:device2) { create(:device, :pc, pic: product_owner2, project: project2) }

  path "/devices" do
    parameter name: "Authorization", in: :header, type: :string, description: "Token authorization user"
    get "all devices" do
      tags "Devices"
      produces "application/json"
      response "200", "return all devices" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        run_test! do |response|
          expected = Entities::Device.represent [device1, device2]
          expect(JSON.parse(response.body)).to match_array JSON.parse(expected.to_json)
        end
      end

      response "401", "unauthorized" do
        let(:"Authorization") { nil }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.unauthorized,
              message: I18n.t("api_error.unauthorized")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end
end
