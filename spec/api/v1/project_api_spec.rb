# frozen_string_literal: true

require "swagger_helper"

describe "Project API" do
  let(:admin) { FactoryBot.create :employee, :admin }
  let(:admin_token) { FactoryBot.create :employee_token, employee: admin }

  let(:section) { FactoryBot.create :organization, :section }
  let(:section_manager) { FactoryBot.create :employee, organization: section }
  let(:section_manager_token) { FactoryBot.create :employee_token, employee: section_manager }

  let(:other_section) { FactoryBot.create :organization, :section }
  let(:other_section_manager) { FactoryBot.create :employee, organization: other_section }
  let(:other_section_manager_token) { FactoryBot.create :employee_token, employee: other_section_manager }

  let(:group) { FactoryBot.create :organization, :clan, parent: section }
  let(:group_leader) { FactoryBot.create :employee, organization: group }
  let(:group_leader_token) { FactoryBot.create :employee_token, employee: group_leader }

  let(:employee) { FactoryBot.create :employee }
  let(:employee_token) { FactoryBot.create :employee_token, employee: employee }

  let(:sprint) { FactoryBot.create :sprint, project: project, phase: phase }
  let(:employee_level) { FactoryBot.create :employee_level, employee: employee }
  let(:phase) { FactoryBot.create :phase, project: project }

  let!(:project) { FactoryBot.create(:project, product_owner: other_section_manager) }
  let!(:other_project) { FactoryBot.create :project, product_owner: group_leader }
  let!(:effort) { FactoryBot.create :effort, employee_level: employee_level, sprint: sprint }

  before do
    group.update_attributes! manager_id: group_leader.id
    section.update_attributes! manager_id: section_manager.id
    other_section.update_attributes! manager_id: other_section_manager.id
  end

  path "/projects" do
    parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"

    get "All projects" do
      tags "Projects"
      parameter name: :name, in: :query, type: :string, description: "Project Name"
      parameter name: :organization_id, in: :query, type: :integer, description: "Organization ID"
      let(:name) {}
      let(:organization_id) {}
      consumes "application/json"

    include_examples "unauthenticated"

      response "200", "Admin can see all projects" do
        let("Emres-Authorization") { "Bearer #{admin_token.token}" }

        run_test! do |response|
          expected = [Entities::Project.represent(project),
            Entities::Project.represent(other_project)]
          expect(JSON.parse(response.body)).to match_array JSON.parse(expected.to_json)
        end
      end

      response "200", "Manager can see all projects" do
        let("Emres-Authorization") { "Bearer #{group_leader_token.token}" }

        run_test! do |response|
          expected = [Entities::Project.represent(project),
            Entities::Project.represent(other_project)]
          expect(JSON.parse(response.body)).to match_array JSON.parse(expected.to_json)
        end
      end

      response "200", "Employee can see all projects" do
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }

        run_test! do |response|
          expected = [Entities::Project.represent(project),
            Entities::Project.represent(other_project)]
          expect(JSON.parse(response.body)).to match_array JSON.parse(expected.to_json)
        end
      end

      response "200", "return all projects without params" do

        let("Emres-Authorization") { "Bearer #{employee_token.token}" }
        run_test! do |response|
          expected = [Entities::Project.represent(project),
            Entities::Project.represent(other_project)]
            expect(JSON.parse(response.body)).to match_array JSON.parse(expected.to_json)
        end
      end

      response "200", "return projects match with params name" do

        let("Emres-Authorization") { "Bearer #{employee_token.token}" }
        let(:name) { project.name }
        run_test! do |response|
          expected = [Entities::Project.represent(project)]
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return projects have PO's org in organization_id + child" do
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }
        let(:organization_id) { section.id }
        run_test! do |response|
          expected = [Entities::Project.represent(other_project)]
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return nill when any project match name" do
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }
        let(:name) { "123 project_name 123" }
        let(:organization_id) { group.id }
        run_test! do |response|
          expected = []
          expect(response.body).to eq expected.to_json
        end
      end

      response "404", "return error when any project match organization_id + child" do
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }
        let(:name) { project.name }
        let(:organization_id) { 0 }
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

      response "200", "return projects match with params name and organization_id + child" do
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }
        let(:name) { other_project.name }
        let(:organization_id) { group.id }
        run_test! do |response|
          expected = [Entities::Project.represent(other_project)]
          expect(response.body).to eq expected.to_json
        end
      end
    end

    post "Create a project" do
      tags "Projects"
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, description: "Project name" },
          product_owner_id: { type: :integer, description: "Product owner" },
          starts_on: { type: :date, description: "Project start time" }
        },
        required: [:name, :product_owner_id]
      }

      response "201", "Admin can create" do
        let("Emres-Authorization") { "Bearer #{admin_token.token}" }
        let(:params) { {
          name: "Project 1",
          product_owner_id: admin.id,
          starts_on: 3.days.ago
        } }

        run_test! do |response|
          expected = Entities::Project.represent Project.last
          expect(response.body).to eq expected.to_json
        end
      end

      response "201", "Manager can create a project" do
        let("Emres-Authorization") { "Bearer #{group_leader_token.token}" }
        let(:params) { {
          name: "Project 1",
          product_owner_id: admin.id,
          starts_on: 3.days.ago
        } }

        run_test! do |response|
          expected = Entities::Project.represent Project.last
          expect(response.body).to eq expected.to_json
        end
      end

      response "403", "Employee cannot create" do
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }

        let(:params) {
          {
            name: "Project 1",
            product_owner_id: admin.id,
            starts_on: 3.days.ago
          }
        }

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

      response "400", "missing param name" do
        let("Emres-Authorization") { "Bearer #{admin_token.token}" }
        let(:params) {
          { product_owner_id: 1 }
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
    end
  end

  path "/projects/{id}" do
    parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"

    get "Get information of specific project" do
      tags "Projects"
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer, description: "Project ID"
      response "200", "Admin can see any project" do
        let("Emres-Authorization") { "Bearer #{admin_token.token}" }
        let(:id) { other_project.id }
        run_test! do
          expected = Entities::ProjectDetail.represent(other_project)
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "Manager can see any project" do
        let("Emres-Authorization") { "Bearer #{group_leader_token.token}" }
        let(:id) { project.id }
        run_test! do
          expected = Entities::ProjectDetail.represent(project)
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "Employee can see project that employee belongs to" do
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }
        let(:employee_level) { FactoryBot.create :employee_level, employee: employee }
        let(:sprint) { FactoryBot.create :sprint, project: project }
        let!(:effort) { FactoryBot.create :effort, employee_level: employee_level, sprint: sprint }
        let(:id) { project.id }

        run_test! do
          expected = Entities::ProjectDetail.represent(project)
          expect(response.body).to eq expected.to_json
        end
      end

      response "403", "Employee cannot see project that employee does not belongs to" do
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }
        let(:id) { other_project.id }

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

      response "404", "project not found" do
        let(:id) { 0 }
        let("Emres-Authorization") { "Bearer #{admin_token.token}" }

        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Project.name, id: id)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end

    patch "Update an project" do
      tags "Projects"
      consumes "application/json"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, description: "Project name" },
          description: { type: :string, description: "Project description" },
          product_owner_id: { type: :integer, description: "Product owner" },
          starts_on: { type: :date, description: "Project start time" }
        }
      }
      parameter name: :id, in: :path, type: :integer, description: "Project ID"

      response "200", "product owner can update project that product owner created" do
        let("Emres-Authorization") { "Bearer #{group_leader_token.token}" }
        let(:id) { other_project.id }
        let(:params) {
          { name: "Manager's Project", description: "Project description", product_owner_id: group_leader.id }
        }
        run_test! do |response|
          expected = other_project.reload
          expect(expected.name).to eq "Manager's Project"
          expect(expected.description).to eq "Project description"
          expect(expected.product_owner).to eq group_leader
          expect(response.body).to eq Entities::Project.represent(expected).to_json
        end
      end

      response "200", "manager of product owner can update project that product owner created" do
        let("Emres-Authorization") { "Bearer #{section_manager_token.token}" }
        let(:id) { other_project.id }
        let(:params) {
          { name: "Manager's Project", description: "Project description", product_owner_id: group_leader.id }
        }
        run_test! do |response|
          expected = other_project.reload
          expect(expected.name).to eq "Manager's Project"
          expect(expected.description).to eq "Project description"
          expect(expected.product_owner).to eq group_leader
          expect(response.body).to eq Entities::Project.represent(expected).to_json
        end
      end

      response "403", "manager, but not manage product owner cannot update project that product owner created" do
        let("Emres-Authorization") { "Bearer #{other_section_manager_token.token}" }
        let(:id) { other_project.id }
        let(:params) {
          { name: "Manager's Project", description: "Project description", product_owner_id: group_leader.id }
        }
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

      response "200", "admin can update a project" do
        let(:id) { project.id }
        let("Emres-Authorization") { "Bearer #{admin_token.token}" }
        let(:params) {
          { name: "Employee's Project", description: "Project description", product_owner_id: employee.id }
        }
        run_test! do |response|
          expected = project.reload
          expect(expected.name).to eq "Employee's Project"
          expect(expected.description).to eq "Project description"
          expect(expected.product_owner).to eq employee
          expect(response.body).to eq Entities::Project.represent(expected).to_json
        end
      end

      response "403", "Employee cannot update" do
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }
        let(:id) { project.id }
        let(:params) {
          { name: "Test Project", product_owner_id: employee.id }
        }
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

    delete "Delete project" do
      tags "Projects"
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer, description: "Project ID"

      response "200", "admin delete successfully" do
        let(:id) { project.id }
        let("Emres-Authorization") { "Bearer #{admin_token.token}" }

        run_test! do
          expected = {
            message: I18n.t("delete_success")
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "manager delete successfully" do
        let(:id) { other_project.id }
        let("Emres-Authorization") { "Bearer #{group_leader_token.token}" }

        run_test! do
          expected = {
            message: I18n.t("delete_success")
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "403", "employee cannot delete project" do
        let(:id) { project.id }
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }

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

  path "/projects/{id}/employees" do
    parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"

    get "Get employees in project" do
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer, description: "Project ID"

      response "200", "Amdin, GL above and PO can see all employee" do
        let("Emres-Authorization") { "Bearer #{admin_token.token}" }
        let(:id) { project.id }
        run_test! do
          expected = [Entities::Employee.represent(employee)]
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "Employee in project can see" do
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }
        let(:id) { project.id }
        run_test! do
          expected = [Entities::Employee.represent(employee)]
          expect(response.body).to eq expected.to_json
        end
      end

      response "403", "Employee not in project can't see employee in project" do
        let(:employee_1) { FactoryBot.create :employee }
        let(:employee_token_1) { FactoryBot.create :employee_token, employee: employee_1 }
        let("Emres-Authorization") { "Bearer #{employee_token_1.token}" }
        let(:id) { project.id }

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

      response "404", "project not found" do
        let(:id) { 0 }
        let("Emres-Authorization") { "Bearer #{admin_token.token}" }

        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Project.name, id: id)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end
end
