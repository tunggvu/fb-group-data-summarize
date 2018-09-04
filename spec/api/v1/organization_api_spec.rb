# frozen_string_literal: true

require "swagger_helper"

describe "Organization API" do
  let!(:division) { FactoryBot.create(:organization, :division, name: "Division 1") }
  let!(:division2) { FactoryBot.create(:organization, :division, name: "Division 2") }
  let!(:section) { FactoryBot.create(:organization, :section, parent: division2) }
  let!(:section2) { FactoryBot.create(:organization, :section, parent: division2) }

  let!(:employee) { FactoryBot.create :employee, organization: section }
  let(:employee_token) { FactoryBot.create :employee_token, employee: employee }

  let!(:manager) { FactoryBot.create :employee, organization: division }
  let(:manager_token) { FactoryBot.create :employee_token, employee: manager }

  let!(:admin) { FactoryBot.create :employee, :admin, organization: nil }
  let(:admin_token) { FactoryBot.create :employee_token, employee: admin }

  before do
    division2.update manager_id: manager.id
  end

  path "/api/v1/organizations" do
    parameter name: "Authorization", in: :header, type: :string
    get "organization tree" do
      tags "Organizations"
      consumes "application/json"
      response "200", "return application tree" do
        examples "application/json" => [{
            id: 1,
            name: "Division 1",
            parent_id: nil,
            manager_id: 2,
            level: "division",
            children: [{
              id: 2,
              name: "Section 1",
              parent_id: 1,
              manager_id: 3,
              level: "section",
              children: [{
                id: 3,
                name: "Group 1",
                parent_id: 2,
                manager_id: 4,
                level: "clan",
                children: [{
                  id: 4,
                  name: "Team 1",
                  parent_id: 3,
                  manager_id: 5,
                  level: "team",
                  children: []
                }]
              }]
            }]
          },
          {
            id: 10,
            name: "Division 2",
            parent_id: nil,
            manager_id: 12,
            level: "division",
            children: []
          }]

        let(:"Authorization") { "Bearer #{employee_token.token}" }
        run_test! do |response|
          expected = [
            Entities::BaseOrganization.represent(division),
            Entities::BaseOrganization.represent(division2)
          ]
          expect(JSON.parse(response.body)).to match_array JSON.parse(expected.to_json)
        end
      end

      response "401", "unauthorized" do
        examples "application/json" =>  {
          error: {
            code: Settings.error_formatter.http_code.unauthorized,
            message: I18n.t("api_error.unauthorized")
          }
        }

        let(:"Authorization") { nil }
        let(:id) { section.id }
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

    post "Create an organization" do
      tags "Organizations"
      consumes "application/json"
      parameter name: :organization, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          manager_id: { type: :integer },
          level: { type: :integer },
          parent_id: { type: :integer }
        },
        required: [:name, :manager_id, :level]
      }

      response "201", "created an organization" do
        examples "application/json" => {
            id: 3,
            name: "Group 1",
            parent_id: 2,
            manager_id: 4,
            level: "clan",
            children: []
          }

        let(:organization) {
          {
             name: "Test Organization",
             manager_id: manager.id,
             level: 2,
             parent_id: Organization.first.id
          }
        }
        let(:"Authorization") { "Bearer #{admin_token.token}" }
        run_test! do |response|
          expected = Entities::BaseOrganization.represent Organization.last
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "validation failed" do
        examples "application/json" =>  {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: I18n.t("api_error.missing_params", params: "name")
          }
        }

        let(:organization) { { manager_id: 100, level: 4 } }
        let(:"Authorization") { "Bearer #{admin_token.token}" }
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

      response "401", "unauthorized" do
        examples "application/json" =>  {
          error: {
            code: Settings.error_formatter.http_code.unauthorized,
            message: I18n.t("api_error.unauthorized")
          }
        }

        let(:organization) {
          {
            name: "Test Organization",
             manager_id: 100,
             level: 4
          }
        }
        let(:"Authorization") { "Bearer #{employee_token.token}" }
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

  path "/api/v1/organizations/{id}" do
    parameter name: "Authorization", in: :header, type: :string
    let(:"Authorization") { "Bearer #{admin_token.token}" }

    get "Information of an organization" do
      tags "Organizations"
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer, description: "Organization ID"
      response "200", "returns the organization information" do
        examples "application/json" => {
            id: 1,
            parent_id: nil,
            manager_id: 2,
            level: "division",
            name: "Division 1",
            children: [
              {
                id: 2,
                parent_id: 1,
                manager_id: 3,
                level: "section",
                name: "Section 1",
                children: [
                  {
                    id: 3,
                    parent_id: 2,
                    manager_id: 4,
                    level: "clan",
                    name: "Clan 1",
                    children: [
                      {
                        id: 4,
                        parent_id: 3,
                        manager_id: 5,
                        level: "team",
                        name: "Team 1",
                        children: []
                      },
                      {
                        id: 5,
                        parent_id: 3,
                        manager_id: 6,
                        level: "team",
                        name: "Team 2",
                        children: []
                      }
                    ]
                  }
                ]
              }
            ]
          }

        let(:id) { division2.id }
        run_test! do |response|
          expected = Entities::Organization.represent division2
          expect(response.body).to eq expected.to_json
        end
      end

      response "404", "returns invalid id error" do
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.record_not_found,
            message: I18n.t("api_error.invalid_id", model: Organization.name, id: 0)
          }
        }

        let(:id) { 0 }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Organization.name, id: id)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end

    patch "Update an organization" do
      tags "Organizations"
      consumes "application/json"
      parameter name: :organization, in: :body, schema: {
        type: :object,
        properties: {
          name: {type: :string, description: "Organization name"},
          manager_id: {type: :integer, description: "Organization manager"},
          level: {type: :integer, description: "Organization level"},
          parent_id: {type: :integer, description: "Organization parent"}
        },
        required: [:name, :manager_id, :level]
      }
      parameter name: :id, in: :path, type: :integer, description: "Organization ID"

      response "200", "updated an organization" do
        examples "application/json" => {
            id: 3,
            name: "Group 1",
            parent_id: 2,
            manager_id: 4,
            level: "clan",
            children: []
          }

        let(:organization) {
          {
            name: "Test Section",
            manager_id: employee.id,
            level: 3,
            parent_id: division.id
          }
        }
        let(:id) { section.id }
        run_test! do |response|
          expected = Entities::BaseOrganization.represent section.reload
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "validation failed" do
        examples "application/json" =>  {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.missing_params", params: "name")
            }
          }

        let(:organization) { { manager_id: 100,
                               level: 3 }
        }
        let(:id) { section.id }
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

      response "401", "unauthorized" do
        examples "application/json" =>  {
            error: {
              code: Settings.error_formatter.http_code.unauthorized,
              message: I18n.t("api_error.unauthorized")
            }
          }

        let(:organization) {
          {
            name: "Test Organization",
            manager_id: manager.id,
            level: 1
          }
        }
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:id) { division2.id }
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

      response "404", "not found organization" do
        examples "application/json" => {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Organization.name, id: 0)
            }
          }

        let(:organization) {
          {
            name: "Test Organization",
            manager_id: manager.id,
            level: :clan,
            parent_id: Organization.first.id
          }
        }
        let(:id) { 0 }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Organization.name, id: id)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end

    delete "Deletes an organization" do
      tags "Organizations"
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer, description: "Organization ID"

      response "200", "deleted an organization" do
        examples "application/json" =>  {
          message: I18n.t("delete_success")
        }

        let(:id) { division2.id }
        let!(:other_employee) { FactoryBot.create :employee, organization: division2 }
        run_test! do |response|
          expected = { message: I18n.t("delete_success") }
          expect(response.body).to eq expected.to_json
          expect(Organization.count).to eq 1
          expect(Employee.count).to eq 4
          expect { division2.reload }.to raise_error ActiveRecord::RecordNotFound
          expect(other_employee.reload.organization).to be_nil
        end
      end

      response "401", "unauthorized" do
        examples "application/json" =>  {
          error: {
            code: Settings.error_formatter.http_code.unauthorized,
            message: I18n.t("api_error.unauthorized")
          }
        }

        let(:"Authorization") { "Bearer #{manager_token.token}" }
        let(:id) { section.id }
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

      response "404", "not found organization" do
        examples "application/json" => {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Organization.name, id: 0)
            }
          }

        let(:"Authorization") { "Bearer #{admin_token.token}" }
        let(:id) { 0 }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Organization.name, id: id)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end

  path "/api/v1/organizations/{id}/employees" do
    parameter name: "Authorization", in: :header, type: :string
    let(:id) { division2.id }

    patch "Update an organization for employees" do
      tags "Organizations"
      consumes "application/json"

      parameter name: :employees, in: :body, schema: {
        type: :object,
        properties: {
          employees: [{type: :integer}]
        },
      }
      parameter name: :id, in: :path, type: :integer, description: "Organization ID"

      response "401", "member cannot add employee" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:employee2) { FactoryBot.create :employee }
        let(:employee1) { FactoryBot.create :employee }
        let(:employees) {
          {
            employees: [employee1.id, employee2.id]
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

      response "401", "manager of other organization cannot add employee" do
        let(:manager2) { FactoryBot.create :employee, organization: division }
        let(:manager2_token) { FactoryBot.create :employee_token, employee: manager2 }

        before do
          division.update manager_id: manager2.id
        end

        let(:"Authorization") { "Bearer #{manager2_token.token}" }
        let(:employee2) { FactoryBot.create :employee }
        let(:employee1) { FactoryBot.create :employee }
        let(:employees) {
          {
            employees: [employee1.id, employee2.id]
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

      response "200", "return blank array if params is blank" do
        let(:"Authorization") { "Bearer #{admin_token.token}" }
        let(:employees) {
          {
            employees: []
          }
        }
        examples "application/json" =>
          []

        run_test! do |response|
          expected = []
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "admin can add employee" do
        let(:"Authorization") { "Bearer #{admin_token.token}" }
        let(:employee2) { FactoryBot.create :employee }
        let(:employee1) { FactoryBot.create :employee }
        let(:employees) {
          {
            employees: [employee1.id, employee2.id]
          }
        }
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
            Entities::Employee.represent(employee1.reload),
            Entities::Employee.represent(employee2.reload)
          ]
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "manager of organization can add employee" do
        let(:"Authorization") { "Bearer #{manager_token.token}" }
        let(:employee2) { FactoryBot.create :employee }
        let(:employee1) { FactoryBot.create :employee }
        let(:employees) {
          {
            employees: [employee1.id, employee2.id]
          }
        }

        examples "application/json" => [
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
        run_test! do
          expected = [
            Entities::Employee.represent(employee1.reload),
            Entities::Employee.represent(employee2.reload)
          ]
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end

  path "/api/v1/organizations/{id}/employees/{employee_id}" do
    parameter name: "Authorization", in: :header, type: :string
    parameter name: :id, in: :path, type: :integer, description: "Organization ID"
    parameter name: :employee_id, in: :path, type: :integer, description: "Employee ID"
    let(:"Authorization") { "Bearer #{admin_token.token}" }
    let(:id) { division2.id }
    let(:employee_id) { employee.id }

    delete "Deletes an organization employee" do
      tags "Organizations"
      consumes "application/json"

      response "200", "admin can delete employee" do
        examples "application/json" => {
          message: I18n.t("delete_success")
        }

        run_test! do |response|
          expected = {
            message: I18n.t("delete_success")
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "manager of organization can delete employee" do
        examples "application/json" => {
          message: I18n.t("delete_success")
        }

        let(:"Authorization") { "Bearer #{manager_token.token}" }

        run_test! do |response|
          expected = {
            message: I18n.t("delete_success")
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "404", "not found employee" do
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.record_not_found,
            message: I18n.t("api_error.invalid_id", model: Employee.name, id: 0)
          }
        }

        let(:employee_id) { 0 }
        run_test! do |response|
          message = I18n.t("api_error.invalid_id", model: Employee.name, id: employee_id)
          expect(response.body).to include message
        end
      end

      response "404", "not found organization" do
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.record_not_found,
            message: I18n.t("api_error.invalid_id", model: Organization.name, id: 0)
          }
        }

        let(:id) { 0 }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Organization.name, id: id)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "404", "cannot delete employee not in organization" do
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.record_not_found,
            message: I18n.t("api_error.invalid_id", model: Employee.name, id: 0)
          }
        }

        let(:"Authorization") { "Bearer #{admin_token.token}" }
        let(:id) { section2.id }
        run_test! do |response|
          message = I18n.t("api_error.invalid_id", model: Employee.name, id: employee_id)
          expect(response.body).to include message
        end
      end

      response "401", "employee cannot delete employee" do
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.unauthorized,
            message: I18n.t("api_error.unauthorized")
          }
        }

        let(:"Authorization") { "Bearer #{employee_token.token}" }
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

      response "401", "manager of other organization cannot delete employee" do
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.unauthorized,
            message: I18n.t("api_error.unauthorized")
          }
        }

        let(:other_manager) { FactoryBot.create :employee, organization: division }
        let(:other_manager_token) { FactoryBot.create :employee_token, employee: other_manager }
        let(:"Authorization") { "Bearer #{other_manager_token.token}" }
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

      response "401", "unauthorized" do
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.unauthorized,
            message: I18n.t("api_error.unauthorized")
          }
        }

        let(:"Authorization") { "" }
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
