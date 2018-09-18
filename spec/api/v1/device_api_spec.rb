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

  path "/devices/{id}" do
    parameter name: "Authorization", in: :header, type: :string, description: "Token authorization user"
    parameter name: :id, in: :path, type: :integer, description: "Device ID"
    let(:"Authorization") { "Bearer #{employee_token.token}" }
    let(:id) { device1.id }

    get "Show device's infomation" do
      tags "Devices"
      consumes "application/json"

      response "401", "unauthenticated user" do
        let(:"Authorization") { "" }

        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.unauthenticated,
            message: I18n.t("api_error.unauthorized")
          }
        }
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.unauthenticated,
              message: I18n.t("api_error.unauthorized")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "404", "device not found" do
        let(:id) { 0 }

        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.record_not_found,
            message: I18n.t("api_error.invalid_id", model: Device.name, id: 0)
          }
        }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Device.name, id: id)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "device has been found" do
        examples "application/json" => [
          {
            id: 1,
            name: "laptop 0",
            serial_code: "546031702833217",
            device_type: "laptop",
            os_version: "Tyrell Jenkins",
            project: {
              id: 3,
              name: "Stanford Carroll",
              description: nil,
              starts_on: "2018-09-15",
              logo: "/uploads/avatar.png",
              product_owner: {
                  id: 2,
                  organization_id: 1,
                  name: "Gussie D'Amore Sr.",
                  employee_code: "B1210001",
                  email: "gussie.d'amore.sr.@framgia.com",
                  birthday: nil,
                  phone: "0987654321",
                  avatar: "/uploads/avatar.png"
              }
            },
            pic: {
              id: 251,
              organization_id: 39,
              name: "Chasity Bauch",
              employee_code: "B1210250",
              email: "chasity.bauch@framgia.com",
              birthday: nil,
              phone: "0987654321",
              avatar: "/uploads/avatar.png"
            }
          }
        ]

        run_test! do
          expected = Entities::Device.represent device1
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end
end
