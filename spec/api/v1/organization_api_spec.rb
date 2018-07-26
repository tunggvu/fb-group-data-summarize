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
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "unauthorized" do
        examples "application/json" =>  {
          error: {
            code: Settings.error_formatter.http_code.unauthorized,
            message: "unauthorized"
          }
        }

        let(:"Authorization") { nil }
        let(:id) { section.id }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.unauthorized,
              message: "unauthorized"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end

    post "Create an organization" do
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
            message: "name is missing"
          }
        }

        let(:organization) { { manager_id: 100, level: 4 } }
        let(:"Authorization") { "Bearer #{admin_token.token}" }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: "name is missing"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "unauthorized" do
        examples "application/json" =>  {
          error: {
            code: Settings.error_formatter.http_code.unauthorized,
            message: "unauthorized"
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
              message: "unauthorized"
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
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer, description: "Organization ID"
      response "200", "returns the organization information" do
        examples "application/json" => {
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
            message: "Couldn't find Organization with 'id'=100"
          }
        }

        let(:id) { 0 }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: "Couldn't find Organization with 'id'=#{id}"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end

    patch "Update an organization" do
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
              message: "name is missing"
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
              message: "name is missing"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "unauthorized" do
        examples "application/json" =>  {
            error: {
              code: Settings.error_formatter.http_code.unauthorized,
              message: "unauthorized"
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
              message: "unauthorized"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "404", "not found organization" do
        examples "application/json" => {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: "Couldn't find Organization with 'id'=100"
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
              message: "Couldn't find Organization with 'id'=#{id}"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end

    delete "Deletes an organization" do
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer, description: "Organization ID"

      response "200", "deleted an organization" do
        examples "application/json" =>  {
          message: "Delete successfully"
        }

        let(:id) { division2.id }
        let!(:other_employee) { FactoryBot.create :employee, organization: division2 }
        run_test! do |response|
          expected = { message: "Delete successfully" }
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
            message: "unauthorized"
          }
        }

        let(:"Authorization") { "Bearer #{manager_token.token}" }
        let(:id) { section.id }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.unauthorized,
              message: "unauthorized"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "404", "not found organization" do
        examples "application/json" => {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: "Couldn't find Organization with 'id'=100"
            }
          }

        let(:"Authorization") { "Bearer #{admin_token.token}" }
        let(:id) { 0 }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: "Couldn't find Organization with 'id'=#{id}"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end
end
