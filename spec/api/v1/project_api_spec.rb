# frozen_string_literal: true

require "swagger_helper"

describe "Project API" do
  let!(:admin) { FactoryBot.create :employee, :admin }
  let(:admin_token) { FactoryBot.create :employee_token, employee: admin }
  let!(:employee) { FactoryBot.create :employee }
  let(:employee_token) { FactoryBot.create :employee_token, employee: employee }
  let!(:project) { FactoryBot.create(:project, product_owner: admin) }
  let!(:other_project) { FactoryBot.create :project, product_owner: admin }

  path "/api/v1/projects" do
    parameter name: "Authorization", in: :header, type: :string
    let(:"Authorization") { "Bearer #{admin_token.token}" }

    get "All projects" do
      consumes "application/json"

      response "200", "return all projects" do
        examples "application/json" => [
          {
            id: 1,
            name: "Project 1",
            product_owner: {
              id: 1,
              organization_id: 1,
              name: "Employee",
              employee_code: "B120000",
              email: "employee@framgia.com",
              birthday: "1/1/2018",
              phone: "0123456789"
            }
          },
          {
            id: 2,
            name: "Project 2",
            product_owner: {
              id: 1,
              organization_id: 1,
              name: "Employee",
              employee_code: "B120000",
              email: "employee@framgia.com",
              birthday: "1/1/2018",
              phone: "0123456789"
            }
          }
        ]
        run_test! do |response|
          expected = [Entities::Project.represent(project),
            Entities::Project.represent(other_project)]
            expect(response.body).to eq expected.to_json
        end
      end
    end

    post "Create a project" do
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, description: "Project name" },
          product_owner_id: { type: :integer, description: "Product owner" }
          },
        required: [:name, :product_owner_id]
      }

      response "201", "Create a project" do
        examples "application/json" => {
          id: 2,
          name: "Project 1",
          product_owner_id: 2
        }

        let(:params) { {
          name: "Project 1",
          product_owner_id: admin.id
        } }

        run_test! do |response|
          expected = Entities::Project.represent Project.last
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "missing param name" do
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: "name is missing"
          }
        }

        let(:params) {
          { product_owner_id: 1 }
        }
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

      response "401", "unauthorized create project" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.unauthorized,
            message: "unauthorized"
          }
        }
        let(:params) {
          { name: "Test Project", product_owner_id: employee.id }
        }
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

  path "/api/v1/projects/{id}" do
    parameter name: "Authorization", in: :header, type: :string
    let(:"Authorization") { "Bearer #{admin_token.token}" }

    get "Get information of specific project" do
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer
      response "200", "return a project" do
        examples "application/json" => {
          id: 1,
          name: "Project 1",
          product_owner: {
            id: 1,
            organization_id: 1,
            name: "Employee",
            employee_code: "B120000",
            email: "employee@framgia.com",
            birthday: "1/1/2018",
            phone: "0123456789"
          }
        }

        let(:id) { project.id }
        run_test! do
          expected = Entities::Project.represent(project)
          expect(response.body).to eq expected.to_json
        end
      end
      response "404", "project not found" do
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.record_not_found,
            message: "Couldn't find Project with 'id'=0"
          }
        }

        let(:id) { 0 }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: "Couldn't find Project with 'id'=#{id}"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end

    patch "Update an project" do
      consumes "application/json"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, description: "Project name" },
          product_owner_id: { type: :integer, description: "Product owner" }
          },
        required: [:name, :product_owner_id]
      }
      parameter name: :id, in: :path, type: :integer

      response "200", "update a project" do
        let(:id) { project.id }
        examples "application/json" => {
          id: 1,
          name: "Project 1",
          product_owner: {
            id: 1,
            organization_id: 1,
            name: "Employee",
            employee_code: "B120000",
            email: "employee@framgia.com",
            birthday: "1/1/2018",
            phone: "0123456789"
          }
        }

        let(:params) {
          { name: "Employee's Project", product_owner_id: employee.id }
        }
        run_test! do |response|
          expected = project.reload
          expect(expected.name).to eq "Employee's Project"
          expect(expected.product_owner).to eq employee
          expect(response.body).to eq Entities::Project.represent(expected).to_json
        end
      end

      response "400", "missing params product owner " do
        let(:id) { project.id }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: "product_owner_id is missing"
          }
        }

        let(:params) { { name: "Test Project" } }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: "product_owner_id is missing"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "unauthorized" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:id) { project.id }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.unauthorized,
            message: "unauthorized"
          }
        }

        let(:params) {
          { name: "Test Project", product_owner_id: employee.id }
        }
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

    delete "delete project" do
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer

      response "200", "delete successfully" do
        let(:id) { project.id }
        examples "application/json" => {
          message: "Delete successfully"
        }
        run_test! do
          expected = {
            message: "Delete successfully"
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "404", "not found project" do
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.record_not_found,
            message: "Couldn't find Project with 'id'=100"
          }
        }
        let(:id) { 0 }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: "Couldn't find Project with 'id'=#{id}"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "unauthorized delete project" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:id) { project.id }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.unauthorized,
            message: "unauthorized"
          }
        }
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
end
