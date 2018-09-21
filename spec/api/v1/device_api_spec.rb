# frozen_string_literal: true

require "swagger_helper"

describe "Device API" do
  let(:division) { create(:organization, :division, name: "Division 1") }
  let(:section) { create(:organization, :section, parent: division) }
  let(:employee) { create :employee, organization: section }
  let(:product_owner1) { create :employee, organization: division }
  let(:product_owner2) { create :employee, organization: division }
  let(:employee_token) { create :employee_token, employee: employee }
  let(:po1_token) { create :employee_token, employee: product_owner1 }
  let(:project1) { create :project, product_owner: product_owner1 }
  let(:project2) { create :project, product_owner: product_owner2 }
  let(:pic1) { create :employee, organization: division }
  let(:pic1_token) { create :employee_token, employee: pic1 }
  let(:po1_token) { create :employee_token, employee: product_owner1 }
  let!(:device1) { create(:device, :laptop, project: project1) }
  let!(:device2) { create(:device, :pc, project: project2) }

  before do
    device1.update_attributes! pic: pic1
  end

  path "/devices" do
    parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"
    get "all devices" do
      tags "Devices"
      produces "application/json"
      response "200", "return all devices" do
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }
        run_test! do |response|
          expected = Entities::Device.represent [device1, device2]
          expect(JSON.parse(response.body)).to match_array JSON.parse(expected.to_json)
        end
      end

      response "401", "unauthorized" do
        let("Emres-Authorization") { nil }
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

    post "Create device" do
      tags "Devices"
      consumes "application/json"
      let("Emres-Authorization") { "Bearer #{po1_token.token}" }

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: {type: :string, description: "Device name"},
          serial_code: {type: :string, description: "Device serial code"},
          os_version: {type: :string, description: "Os of device"},
          device_type: {type: :integer, description: "Device type 1 2 3"},
          pic_id: {type: :integer, description: "Person in charge"},
          project_id: {type: :integer, description: "project id of pic"},
        }
      }

      response "401", "member cannot create device" do
        let("Emres-Authorization") { nil }
        let(:params) {
          {
            name: "Macbook air 2018",
            serial_code: "3242345542354353",
            device_type: 1,
            os_version: "Window10",
            project_id: project1.id,
            pic_id: employee.id,
          }
        }
        examples "application/json" => {
            error: {
              code: Settings.error_formatter.http_code.unauthorized,
              message: I18n.t("api_error.unauthorized")
            }
        }
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.unauthorized,
              message: I18n.t("api_error.unauthorized")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "201", "Po created device successfully" do
        let(:params) {
          {
            name: "Macbook Air 2018",
            serial_code: "22243423423",
            device_type: 1,
            os_version: "Window10",
            project_id: project1.id,
            pic_id: employee.id
          }
        }
        examples "application/json" => {
          id: 1,
          name: "Macbook Air 2018",
          serial_code: "2333124444334",
          device_type: 1,
          os_version: "Window10",
        }
        run_test! do
          expected = Entities::Device.represent Device.last
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "name validation failed - missing" do
        let(:params) {
          {
            serial_code: "DV123456",
            device_type: 1,
            os_version: "Window10",
            project_id: project1.id,
            pic_id: employee.id
          }
        }
        examples "application/json" =>  {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: I18n.t("api_error.missing_params", params: "name")
          }
        }

        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.missing_params", params: "name")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "validation failed: Project must exist" do
        let(:params) {
          {
            name: "Macbook air 2018",
            serial_code: "42342344124",
            device_type: 1,
            os_version: "Window10",
            pic_id: employee.id
          }
        }
        examples "application/json" =>  {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: I18n.t("api_error.missing_params", params: "project_id")
          }
        }

        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.missing_params", params: "project_id")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "404", "device not found" do
        let(:params) {
          {
            name: "Macbook Air 2018",
            serial_code: "22243423423",
            device_type: 1,
            os_version: "Window10",
            project_id: 0,
            pic_id: employee.id
          }
        }

        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.record_not_found,
            message: I18n.t("api_error.invalid_id", model: Project.name, id: 0)
          }
        }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Project.name, id: 0)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end

  path "/devices/{id}" do
    parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"
    parameter name: :id, in: :path, type: :integer, description: "Device ID"
    let("Emres-Authorization") { "Bearer #{employee_token.token}" }
    let(:id) { device1.id }

    get "Show device's infomation" do
      tags "Devices"
      consumes "application/json"

      response "401", "unauthenticated user" do
        let("Emres-Authorization") { "" }

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
        run_test! do
          expected = Entities::DeviceDetail.represent device1
          expect(response.body).to eq expected.to_json
        end
      end
    end

    patch "Update device's infomation" do
      tags "Devices"
      consumes "application/json"
      let("Emres-Authorization") { "Bearer #{po1_token.token}" }

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          os_version: { type: :string }
        }
      }

      response "401", "unauthorized product_owner/pic" do
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }
        let(:params) { {
          name: "Test name"
        } }

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
        let(:params) { {
          os_version: "Ubuntu 16.04"
        } }

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

      response "200", "PO Update device successful" do
        let(:params) { {
          os_version: "Ubuntu 18.04"
        } }

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
              product_owner_id: 2
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
          expected = Entities::Device.represent device1.reload
          expect(response.body).to eq expected.to_json
          expect(device1.os_version).to eq "Ubuntu 18.04"
        end
      end

      response "200", "PIC Update device successful" do
        let("Emres-Authorization") { "Bearer #{pic1_token.token}" }
        let(:params) { {
          os_version: "Ubuntu 18.04"
        } }

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
              logo: "/uploads/avatar.png"
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
          expected = Entities::Device.represent device1.reload
          expect(response.body).to eq expected.to_json
          expect(device1.os_version).to eq "Ubuntu 18.04"
        end
      end
    end
  end
end
