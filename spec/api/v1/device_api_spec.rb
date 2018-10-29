# frozen_string_literal: true

require "swagger_helper"

describe "Device API" do
  let(:admin) { create :employee, :admin, organization: nil }
  let(:admin_token) { create :employee_token, employee: admin }
  let(:division) { create(:organization, :division, name: "Division 1") }
  let(:section) { create(:organization, :section, parent: division) }
  let(:employee) { create :employee, organization: section }
  let(:product_owner1) { create :employee, organization: division }
  let(:product_owner2) { create :employee, organization: division }
  let(:employee_token) { create :employee_token, employee: employee }
  let(:po1_token) { create :employee_token, employee: product_owner1 }
  let(:po2_token) { create :employee_token, employee: product_owner2 }
  let(:project1) { create :project, product_owner: product_owner1 }
  let(:project2) { create :project, product_owner: product_owner2 }
  let(:pic1) { create :employee, organization: division }
  let(:pic2) { create :employee, organization: division }
  let(:pic3) { create :employee, organization: division }
  let(:pic1_token) { create :employee_token, employee: pic1 }
  let(:po1_token) { create :employee_token, employee: product_owner1 }
  let!(:device1) { create(:device, :laptop, name: "Device 1", pic: product_owner1, project: project1) }
  let!(:device2) { create(:device, :pc, name: "Device 2", pic: product_owner2, project: project2) }
  let(:skill) { create :skill }
  let(:level) { create :level, skill: skill }
  let(:employee_level1) { create :employee_level, employee: pic1, level: level }
  let(:employee_level2) { create :employee_level, employee: pic2, level: level }
  let(:employee_level3) { create :employee_level, employee: pic3, level: level }
  let(:sprint1) { create :sprint, project: project1, starts_on: project1.starts_on, ends_on: 7.days.from_now }
  let(:sprint2) { create :sprint, project: project2, starts_on: project2.starts_on, ends_on: 7.days.from_now }
  let!(:effort1) { create :effort, sprint: sprint1, employee_level: employee_level1, effort: 80 }
  let!(:effort2) { create :effort, sprint: sprint2, employee_level: employee_level2, effort: 30 }
  let!(:effort3) { create :effort, sprint: sprint1, employee_level: employee_level3, effort: 50 }
  ENV["FRONTEND_HOST"] = "emres@framgia.com"

  before do
    device1.update_attribute :pic, pic1
    device1.requests.create!(request_pic: product_owner1, project: project1, requester: product_owner1, status: :approved)
  end

  path "/devices" do
    parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"
    get "all devices" do
      tags "Devices"
      consumes "application/json"

      parameter name: :query, in: :query, type: :string, description: "Filter device with name, serial code or os version"
      parameter name: "device_types[]", in: :query, type: :array, collectionFormat: :multi, items: { type: :integer }, description: "Filter device with multiple device type"
      parameter name: :project_id, in: :query, type: :integer, description: "Filter device with project id"
      parameter name: :organization_id, in: :query, type: :integer, description: "Filter device with organization id of pic"

      let("Emres-Authorization") { "Bearer #{po1_token.token}" }
      let(:query) {}
      let("device_types[]") { [] }
      let(:project_id) {}
      let(:organization_id) {}
      let(:device_own_ids) { product_owner1.device_ids }
      let(:current_device_requests) { product_owner1.created_requests.is_waiting.ids }

      include_examples "unauthenticated"

      response "200", "return all devices without params" do
        run_test! do |response|
          expected = Entities::DeviceCurrentUser.represent [device1, device2], devices_keeping: device_own_ids, devices_requesting: current_device_requests
          expect(response.body).to eq (expected.to_json)
        end
      end

      response "200", "return devices with query param" do
        let(:query) { device1.name }

        run_test! do |response|

          expected = Entities::DeviceCurrentUser.represent [device1], devices_keeping: device_own_ids, devices_requesting: current_device_requests
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return devices with params device types" do
        let("device_types[]") { [device1.device_type_before_type_cast, device2.device_type_before_type_cast] }
        run_test! do |response|
          expected = Entities::DeviceCurrentUser.represent [device1, device2], devices_keeping: device_own_ids, devices_requesting: current_device_requests
          expect(JSON.parse(response.body)).to match_array JSON.parse(expected.to_json)
        end
      end

      response "200", "return devices with params project_id" do
        let(:project_id) { device1.project_id }

        run_test! do |response|
          expected = Entities::DeviceCurrentUser.represent [device1], devices_keeping: device_own_ids, devices_requesting: current_device_requests
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return devices with params organization_id" do
        let(:organization_id) { division.id }

        run_test! do |response|
          expected = Entities::DeviceCurrentUser.represent [device1, device2], devices_keeping: device_own_ids, devices_requesting: current_device_requests
          expect(JSON.parse(response.body)).to match_array JSON.parse(expected.to_json)
        end
      end

      response "200", "return empty devices" do
        let(:query) { device1.name }
        let(:project_id) { 0 }
        let("device_types[]") { [0] }

        run_test! do |response|
          expect(JSON.parse response.body).to be_empty
        end
      end

      response "200", "return devices with all params" do
        let(:query) { device1.name }
        let(:project_id) { device1.project_id }
        let("device_types[]") { [device1.device_type_before_type_cast] }
        let(:organization_id) { division.id }


        run_test! do |response|
          expected = Entities::DeviceCurrentUser.represent [device1], devices_keeping: device_own_ids, devices_requesting: current_device_requests
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
          name: { type: :string, description: "Device name" },
          serial_code: { type: :string, description: "Device serial code" },
          os_version: { type: :string, description: "Os of device" },
          device_type: { type: :integer, description: "Device type 1 2 3" },
          pic_id: { type: :integer, description: "Person in charge" },
          project_id: { type: :integer, description: "project id of pic" },
        }
      }

      let(:params) {
        {
          name: "Macbook Air 2018",
          serial_code: "22243423423",
          device_type: 1,
          os_version: "Window10",
          project_id: project1.id,
          pic_id: pic1.id
        }
      }

      include_examples "unauthenticated"

      response "403", "member cannot create device" do
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }

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

      include_examples "unauthenticated"

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

      let(:params) { {
        name: "Test name",
        os_version: "Ubuntu 18.04"
      } }

      include_examples "unauthenticated"

      response "403", "unauthorized product_owner/pic" do
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }

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

      response "200", "PO Update device successful" do
        let(:params) { {
          os_version: "Ubuntu 18.04"
        } }

        run_test! do
          expected = Entities::DeviceDetail.represent device1.reload
          expect(response.body).to eq expected.to_json
          expect(device1.os_version).to eq "Ubuntu 18.04"
        end
      end

      response "200", "PIC Update device successful" do
        let("Emres-Authorization") { "Bearer #{pic1_token.token}" }
        let(:params) { {
          os_version: "Ubuntu 18.04"
        } }

        run_test! do
          expected = Entities::DeviceDetail.represent device1.reload
          expect(response.body).to eq expected.to_json
          expect(device1.os_version).to eq "Ubuntu 18.04"
        end
      end

      response "200", "Admin Update device successful" do
        let("Emres-Authorization") { "Bearer #{admin_token.token}" }
        let(:params) {
          {
            os_version: "Ubuntu 18.04"
          }
        }

        run_test! do
          expected = Entities::DeviceDetail.represent device1.reload
          expect(response.body).to eq expected.to_json
          expect(device1.os_version).to eq "Ubuntu 18.04"
        end
      end
    end
  end

  path "/projects/{project_id}/devices/{id}/requests" do
    parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"
    parameter name: :project_id, in: :path, type: :integer, description: "Project ID"
    parameter name: :id, in: :path, type: :integer, description: "Device ID"
    let("Emres-Authorization") { "Bearer #{po1_token.token}" }
    let(:project_id) { project1.id }
    let(:id) { device1.id }

    post "Create request when change owner of device" do
      tags "Devices"
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          request_pic: {type: :integer, description: "PIC of Request"},
          request_project: {type: :integer, description: "Project id of Rquest"}
        },
        required: [:request_pic, :request_project]
      }

      let(:params) {
        {
          request_pic: pic3.id,
          request_project: project1.id
        }
      }

      include_examples "unauthenticated"

      response "201", "Create request successful" do
        run_test! do
          expected = Entities::Request.represent Request.last
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "Missing params request_pic" do
        let(:params) {
          {
            request_project: project1.id
          }
        }

        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.missing_params", params: "request_pic")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "Missing params request_project" do
        let(:params) {
          {
            request_pic: pic1.id
          }
        }

        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.missing_params", params: "request_project")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "403", "unauthorized product_owner/pic/admin" do
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }

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

      response "422", "User doesn't have the right to do" do
        let("Emres-Authorization") { "Bearer #{pic1_token.token}" }
        let(:params) { {
          request_pic: pic2.id,
          request_project: project2.id
        } }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: I18n.t("api_error.device_unchangeable")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "404", "Device not found" do
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

      response "422", "Request pic must belong to project" do
        let(:params) {
          {
            request_pic: employee.id,
            request_project: project1.id
          }
        }

        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: I18n.t("api_error.pic_in_project")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "422", "Request pic and project aren't change" do
        let(:params) {
          {
            request_pic: pic1.id,
            request_project: project1.id
          }
        }

        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: I18n.t("api_error.device_nothing_change")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end

  path "/devices/{id}/requests" do
    parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"
    parameter name: :id, in: :path, type: :integer, description: "Device ID"
    let("Emres-Authorization") { "Bearer #{po2_token.token}" }
    let(:id) { device1.id }

    post "Create request when borrow the device" do
      tags "Devices"
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          request_pic: {type: :integer, description: "PIC of Request"},
          request_project: {type: :integer, description: "Project id of Rquest"}
        },
        required: [:request_pic, :request_project]
      }

      let(:params) {
        {
          request_pic: pic2.id,
          request_project: project2.id
        }
      }

      include_examples "unauthenticated"

      response "201", "Create request successful" do
        run_test! do
          expected = Entities::Request.represent Request.last
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "Missing params request_pic" do
        let(:params) {
          {
            request_project: project2.id
          }
        }

        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.missing_params", params: "request_pic")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "Missing params request_project" do
        let(:params) {
          {
            request_pic: pic2.id
          }
        }

        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.missing_params", params: "request_project")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "403", "unauthorized other product_owner/admin" do
        let("Emres-Authorization") { "Bearer #{po1_token.token}" }

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

      response "422", "User doesn't have the right to do" do
        let("Emres-Authorization") { "Bearer #{po2_token.token}" }
        let(:params) { {
          request_pic: pic3.id,
          request_project: project1.id
        } }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: I18n.t("api_error.device_unchangeable")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "404", "Device not found" do
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

      response "422", "Request pic must belong to project" do
        let(:params) {
          {
            request_pic: employee.id,
            request_project: project2.id
          }
        }

        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: I18n.t("api_error.pic_in_project")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "422", "Request pic and project aren't change" do
        let("Emres-Authorization") { "Bearer #{admin_token.token}" }

        let(:params) {
          {
            request_pic: pic1.id,
            request_project: project1.id
          }
        }

        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: I18n.t("api_error.device_nothing_change")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end
end
