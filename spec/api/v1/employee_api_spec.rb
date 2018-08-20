# frozen_string_literal: true

require "swagger_helper"

describe "Employee API" do
  let(:employee) { FactoryBot.create :employee }
  let(:skill) { FactoryBot.create :skill }
  let(:level) { FactoryBot.create :level, skill: skill }
  let!(:employee_level) { FactoryBot.create :employee_level, employee: employee, level: level }
  let(:employee_token) { FactoryBot.create :employee_token, employee: employee }
  let(:group) { FactoryBot.create(:organization, :clan, name: "Group 1") }
  let(:manager) { FactoryBot.create :employee, organization: group }
  let(:manager_token) { FactoryBot.create :employee_token, employee: manager }
  let(:admin) { FactoryBot.create :employee, :admin }
  let(:admin_token) { FactoryBot.create :employee_token, employee: admin }
  before do
    group.update_attributes(manager_id: manager.id)
  end

  path "/api/v1/employees" do
    parameter name: "Authorization", in: :header, type: :string
    let(:"Authorization") { "Bearer #{employee_token.token}" }

    get "Information of all employees" do
      parameter name: :query, in: :query, type: :string
      parameter name: :organization_id, in: :query, type: :integer
      parameter name: :skill_id, in: :query, type: :integer
      let(:query) {}
      let(:organization_id) {}
      let(:skill_id) {}
      consumes "application/json"

      response "200", "return employee with correct params" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:query) { employee.name }
        let(:organization_id) { employee.organization_id }
        let(:skill_id) { skill.id }
        examples "application/json" =>
          [
            {
              id: 1,
              organization_id: 1,
              name: "Employee",
              employee_code: "B120000",
              email: "employee@framgia.com",
              birthday: "1/1/2018",
              phone: "0123456789",
              avatar: "#"
            }
          ]
        run_test! do |response|
          expected = [Entities::Employee.represent(employee)]
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return employees with 2 params" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:query) { employee.name }
        let(:skill_id) { skill.id }

        examples "application/json" =>
          [
            {
              id: 1,
              organization_id: 1,
              name: "Employee",
              employee_code: "B120000",
              email: "employee@framgia.com",
              birthday: "1/1/2018",
              phone: "0123456789",
              avatar: "#"
            }
          ]
        run_test! do |response|
          expected = [Entities::Employee.represent(employee)]
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return employees with 1 param" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:query) { employee.name }

        examples "application/json" =>
          [
            {
              id: 1,
              organization_id: 1,
              name: "Employee",
              employee_code: "B120000",
              email: "employee@framgia.com",
              birthday: "1/1/2018",
              phone: "0123456789",
              avatar: "#"
            }
          ]
        run_test! do |response|
          expected = [Entities::Employee.represent(employee)]
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return employees without any params" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }

        examples "application/json" =>
          [
            {
              id: 1,
              organization_id: 1,
              name: "Employee",
              employee_code: "B120000",
              email: "employee@framgia.com",
              birthday: "1/1/2018",
              phone: "0123456789",
              avatar: "#"
            },
            {
              id: 2,
              organization_id: 1,
              name: "Eldora Fay",
              employee_code: "B1210001",
              email: "eldora.fay@framgia.com",
              birthday: "1/1/2018",
              phone: "0987654321",
              avatar: "#"
            }
          ]
        run_test! do |response|
          expected = Entities::Employee.represent(Employee.all)
          expect(JSON.parse(response.body)).to match_array JSON.parse(expected.to_json)
        end
      end

      response "200", "return empty employees" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:query) { employee.name }
        let(:organization_id) { 0 }
        let(:skill_id) { 0 }

        examples "application/json" =>
          []
        run_test! do |response|
          expected = []
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "unauthorized" do
        let(:"Authorization") { "" }
        let(:query) { employee.name }
        let(:organization_id) { employee.organization_id }
        let(:skill_id) { skill.id }

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
    end

    post "Create employee" do
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: {type: :string},
          employee_code: {type: :string},
          email: {type: :string},
          organization_id: {type: :integer},
          password: {type: :string}
        }
      }

      response "401", "member cannot create employee" do
        let(:params) {
          {
            name: "New employee",
            employee_code: "B123456",
            email: "new_employee@framgia.com",
            organization_id: group.id,
            password: "Aa@123456"
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

      response "201", "admin create successfully" do
        let(:"Authorization") { "Bearer #{admin_token.token}" }
        let(:params) {
          {
            name: "New employee",
            employee_code: "B123456",
            email: "new_employee@framgia.com",
            organization_id: group.id,
            password: "Aa@123456"
          }
        }
        examples "application/json" => {
          id: 1,
          organization_id: 1,
          name: "Employee",
          employee_code: "B120000",
          email: "employee@framgia.com",
          birthday: "1/1/2018",
          phone: "0123456789",
          avatar: "#"
        }
        run_test! do
          expected = Entities::Employee.represent Employee.last
          expect(response.body).to eq expected.to_json
        end
      end

      response "201", "manager create successfully" do
        let(:"Authorization") { "Bearer #{manager_token.token}" }
        let(:params) {
          {
            name: "New employee",
            employee_code: "B123456",
            email: "new_employee@framgia.com",
            organization_id: group.id,
            password: "Aa@123456"
          }
        }
        examples "application/json" => {
          id: 1,
          organization_id: 1,
          name: "Employee",
          employee_code: "B120000",
          email: "employee@framgia.com",
          birthday: "1/1/2018",
          phone: "0123456789",
          avatar: "#"
        }
        run_test! do
          expected = Entities::Employee.represent Employee.last
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "missing params email" do
        let(:params) {
          {
            name: "New employee",
            employee_code: "B123456",
            organization_id: group.id,
            password: "Aa@123456"
          }
        }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: I18n.t("api_error.missing_params", params: "email")
          }
        }
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.missing_params", params: "email")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "422", "wrong params" do
        let(:"Authorization") { "Bearer #{manager_token.token}" }
        let(:params) {
          {
            name: "New employee",
            employee_code: "B123456",
            email: "email",
            organization_id: group.id,
            password: "Aa@123456"
          }
        }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.data_operation,
            message: I18n.t("api_error.invalid_params", params: "Email")
          }
        }
        before do
          group.update_attributes(manager_id: manager.id)
        end
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: I18n.t("api_error.invalid_params", params: "Email")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "422", "email has been taken" do
        let(:"Authorization") { "Bearer #{manager_token.token}" }
        let(:params) {
          {
            name: "New employee",
            employee_code: "B123456",
            email: employee.email,
            organization_id: group.id,
            password: "Aa@123456"
          }
        }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.data_operation,
            message: I18n.t("api_error.taken_params", params: "Email")
          }
        }
        before do
          group.update_attributes(manager_id: manager.id)
        end
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: I18n.t("api_error.taken_params", params: "Email")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end

  path "/api/v1/employees/{id}" do
    parameter name: "Authorization", in: :header, type: :string
    let(:"Authorization") { "Bearer #{employee_token.token}" }

    get "Get information of specific employee" do
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer

      response "200", "return one employee" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:id) { employee.id }
        examples "application/json" => {
          id: 1,
          organization_id: 1,
          name: "Employee",
          employee_code: "B120000",
          email: "employee@framgia.com",
          birthday: "1/1/2018",
          phone: "0123456789",
          avatar: "#"
        }
        run_test! do
          expected = Entities::Employee.represent employee,
            only: [:id, :organization_id, :name, :employee_code, :email, :birthday, :phone, :avatar]
          expect(response.body).to eq expected.to_json
        end
      end

      response "404", "invalid id" do
        let(:id) { 0 }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.record_not_found,
            message: I18n.t("api_error.invalid_id", model: Employee.name, id: 0)
          }
        }
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Employee.name, id: id)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end

    delete "delete employee" do
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer

      response "401", "member cannot delete" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }

        let(:id) { employee.id }
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

      response "200", "manager can delete" do
        let(:"Authorization") { "Bearer #{manager_token.token}" }

        let(:id) { employee.id }
        examples "application/json" => {
          message: "Delete successfully"
        }
        run_test! do
          expected = {
            message: I18n.t("delete_success")
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "admin can delete" do
        let(:"Authorization") { "Bearer #{admin_token.token}" }

        let(:id) { employee.id }
        examples "application/json" => {
          message: "Delete successfully"
        }
        run_test! do
          expected = {
            message: I18n.t("delete_success")
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end
end
