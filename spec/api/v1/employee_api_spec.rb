# frozen_string_literal: true

require "swagger_helper"

describe "Employee API" do
  let(:employee) { FactoryBot.create :employee }
  let(:skill) { FactoryBot.create :skill }
  let(:level) { FactoryBot.create :level, skill: skill }
  let(:level2) { FactoryBot.create :level, skill: skill }
  let!(:employee_level) { FactoryBot.create :employee_level, employee: employee, level: level }
  let(:employee_token) { FactoryBot.create :employee_token, employee: employee }
  let(:group) { FactoryBot.create(:organization, :clan, name: "Group 1") }
  let(:division) { FactoryBot.create(:organization, :division, name: "Division1") }
  let(:manager) { FactoryBot.create :employee, organization: group }
  let(:manager_token) { FactoryBot.create :employee_token, employee: manager }
  let(:admin) { FactoryBot.create :employee, :admin }
  let(:admin_token) { FactoryBot.create :employee_token, employee: admin }
  let(:project) { FactoryBot.create :project, product_owner: employee }
  let(:phase) { FactoryBot.create :phase, project: project }
  let(:sprint) { FactoryBot.create :sprint, phase: phase, project: project, starts_on: project.starts_on }
  let!(:effort) { FactoryBot.create :effort, sprint: sprint, employee_level: employee_level }

  before do
    group.update_attributes(manager_id: manager.id, parent: division)
  end

  path "/api/v1/employees" do
    parameter name: "Authorization", in: :header, type: :string
    let(:"Authorization") { "Bearer #{employee_token.token}" }

    get "Information of all employees" do
      tags "Employees"
      parameter name: :query, in: :query, type: :string
      parameter name: :organization_id, in: :query, type: :integer
      parameter name: :skill_id, in: :query, type: :integer
      parameter name: :organization_not_in, in: :query, type: :integer
      parameter name: "level_ids[]", in: :query, type: :array, collectionFormat: :multi, items: { type: :integer }
      parameter name: "ids[]", in: :query, type: :array, collectionFormat: :multi, items: { type: :integer }
      parameter name: :project_id, in: :query, type: :integer

      let(:query) {}
      let(:organization_id) {}
      let(:skill_id) {}
      let(:organization_not_in) {}
      let("level_ids[]") { [] }
      let("ids[]") { [] }
      let(:project_id) {}

      consumes "application/json"

      response "200", "return employee with correct params" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:query) { employee.name }
        let(:organization_id) { employee.organization_id }
        let(:skill_id) { skill.id }
        let("level_ids[]") { [level.id, level2.id] }
        let(:project_id) { project.id }

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

      response "200", "return employees with 3 params" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:query) { employee.name }
        let(:skill_id) { skill.id }
        let("level_ids[]") { [level.id, level2.id] }

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

      response "200", "return employees with params organization_not_in" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:organization_not_in) { section.id }
        let(:section) { FactoryBot.create(:organization, :section, parent: division) }
        let(:section2) { FactoryBot.create(:organization, :section, parent: division) }
        let(:clan1) { FactoryBot.create :organization, :clan, parent: section }
        let!(:employee1) { FactoryBot.create :employee, organization: section }
        let!(:employee2) { FactoryBot.create :employee, organization: section2 }
        let!(:employee3) { FactoryBot.create :employee, organization: clan1 }
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
          expected = [
            Entities::Employee.represent(employee),
            Entities::Employee.represent(manager),
            Entities::Employee.represent(employee2)
           ]
          expect(JSON.parse(response.body)).to match_array JSON.parse(expected.to_json)
        end
      end

      response "200", "return employees with params ids" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let("ids[]") { [employee.id, manager.id] }
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
          expected = [
            Entities::Employee.represent(employee),
            Entities::Employee.represent(manager)
           ]
          expect(JSON.parse(response.body)).to match_array JSON.parse(expected.to_json)
        end
      end

      response "200", "return employees with params organization_id" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:organization_id) { division.id }
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
          expected = [
            Entities::Employee.represent(manager)
           ]
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return employees with params project_id" do
        let(:project_id) { project.id }
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

      response "404", "return error when pass organization not existed to params organization_id " do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:organization_id) { 0 }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.record_not_found,
            message: I18n.t("api_error.invalid_id", model: Organization.name, id: 0)
          }
        }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Organization.name, id: 0)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "404", "return error when pass organization not existed to params organization_not_in " do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:organization_not_in) { 0 }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.record_not_found,
            message: I18n.t("api_error.invalid_id", model: Organization.name, id: 0)
          }
        }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Organization.name, id: 0)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return empty employees" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:query) { employee.name }
        let(:skill_id) { 0 }
        let("level_ids[]") { [0] }
        let("ids[]") { [0] }
        let(:project_id) { 0 }

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
        let("level_ids[]") { [level.id, level2.id] }

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
      tags "Employees"
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          employee_code: { type: :string },
          email: { type: :string },
          organization_id: { type: :integer },
          password: { type: :string }
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
      tags "Employees"
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
      tags "Employees"
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

      let(:employee2) { FactoryBot.create :employee, organization: group }
      response "200", "manager can delete" do
        let(:"Authorization") { "Bearer #{manager_token.token}" }

        let(:id) { employee2.id }
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

        let(:id) { employee2.id }
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
