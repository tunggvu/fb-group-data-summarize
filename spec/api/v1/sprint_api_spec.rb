# frozen_string_literal: true

require "swagger_helper"

describe "SprintAPI" do
  let(:section) { create :organization, :section }
  let(:group) { create :organization, :clan, parent: section }
  let(:div2) { create :organization, :division }

  let(:div2_manager) { create :employee, organization: div2 }
  let(:div2_manager_token) { create :employee_token, employee: div2_manager }

  let(:group_leader) { create :employee, organization: group }
  let(:group_leader_token) { create :employee_token, employee: group_leader }

  let(:section_manager) { create :employee, organization: section }
  let(:section_manager_token) { create :employee_token, employee: section_manager }

  let(:employee) { create :employee }
  let(:employee_token) { create :employee_token, employee: employee }

  let(:project) { create :project, product_owner: group_leader }
  let(:phase) { create :phase, project: project }
  let!(:sprint1) { create :sprint, project: project, phase: phase, starts_on: Date.current, ends_on: 3.days.from_now }
  let!(:sprint2) { create :sprint, project: project, phase: phase, starts_on: 4.days.from_now, ends_on: 8.days.from_now }
  let!(:sprint3) { create :sprint, project: project, phase: phase, starts_on: 9.days.from_now, ends_on: 12.days.from_now }
  let(:level) { create :level }

  let(:employee_level) { FactoryBot.create :employee_level, employee: employee, level: level }

  path "/projects/{project_id}/phases/{phase_id}/sprints" do
    parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"
    parameter name: :project_id, in: :path, type: :integer, description: "Project ID"
    parameter name: :phase_id, in: :path, type: :integer, description: "Phase ID"
    let("Emres-Authorization") { "Bearer #{group_leader_token.token}" }
    let(:project_id) { project.id }
    let(:phase_id) { phase.id }

    get "All sprint in phase" do
      tags "Sprints"
      consumes "application/json"

      response "404", "project not found" do
        let(:project_id) { 0 }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Project.name, id: project_id)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "404", "phase not found" do
        let(:phase_id) { 0 }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Phase.name, id: phase_id)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return all sprint" do
        run_test! do
          expected = Entities::Sprint.represent(phase.sprints)
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "not login" do
        let("Emres-Authorization") {}
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

      response "401", "employee isn't in project cannot view all sprints" do
        let(:employee) { FactoryBot.create :employee }
        let(:employee_token) { FactoryBot.create :employee_token, employee: employee }
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.not_authorized_error,
              message: I18n.t("api_error.unauthorized")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end

    post "Create new sprint" do
      tags "Sprints"
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, description: "Sprint's name" },
          starts_on: { type: :date, description: "Starts on of sprint" },
          ends_on: { type: :date, description: "Ends on of sprint" },
          efforts: [
            effort: { type: :integer, description: "Effort number" },
            employee_id: { type: :integer, description: "Employee ID" },
            level_id: { type: :integer, description: "Level ID" }
          ]
        },
        required: [:name, :starts_on, :ends_on]
      }

      let(:params) {
        {
          name: "Sprint 1",
          starts_on: 13.days.from_now,
          ends_on: 15.days.from_now
        }
      }

      response "201", "PO can create sprint" do
        run_test! do |response|
          expected = Entities::SprintMember.represent Sprint.last
          expect(response.body).to eq expected.to_json
        end
      end

      response "201", "PO can create sprint with effort" do
        let!(:employee_level) { create :employee_level, employee: employee, level: level }
        before {
          params[:efforts] = [
            effort: rand(1..100),
            employee_id: employee.id,
            level_id: level.id
          ]
        }

        run_test! do |response|
          expected = Entities::SprintMember.represent Sprint.last
          expect(response.body).to eq expected.to_json
        end
      end

      response "201", "manager of PO can create sprint" do
        let("Emres-Authorization") { "Bearer #{section_manager_token.token}" }
        before { section.update_attributes! manager_id: section_manager.id }

        run_test! do |response|
          expected = Entities::SprintMember.represent Sprint.last
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "empty effort params" do
        before {
          params[:efforts] = [
            effort: rand(1..100),
            employee_id: "",
            level_id: level.id
          ]
        }

        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.empty_params", params: "efforts[0][employee_id]")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "missing effort params" do
        before {
          params[:efforts] = [
            effort: rand(1..100),
            employee_id: employee.id
          ]
        }

        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.missing_params", params: "efforts[0][level_id]")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "422", "invalid effort" do
        let!(:employee_level) { create :employee_level, employee: employee, level: level }
        before {
          params[:efforts] = [
            effort: 101,
            employee_id: employee.id,
            level_id: level.id
          ]
        }

        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: "Validation failed: Efforts effort must be less than or equal to 100"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "201", "manager of PO can create sprint" do
        let("Emres-Authorization") { "Bearer #{section_manager_token.token}" }

        before { section.update_attributes! manager_id: section_manager.id }

        run_test! do |response|
          expected = Entities::SprintMember.represent Sprint.last
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "employee cannot create sprint" do
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

      response "401", "manager in other division cannot create sprint" do
        let("Emres-Authorization") { "Bearer #{div2_manager_token.token}" }


        before { div2.update_attributes! manager_id: div2_manager.id }

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

      response "400", "empty params" do
        before { params[:name] = "" }

        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.empty_params", params: "name")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "missing params" do
        before { params.delete(:name) }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.missing_params", params: "name")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "422", "invalid ends time" do
        let(:params) {
          {
            name: "Sprint 1",
            starts_on: Time.now,
            ends_on: 7.days.ago
          }
        }

        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: I18n.t("api_error.invalid_starts_on_ends_on")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "422", "invalid starts time" do
        before {
          params[:starts_on] = 10.days.from_now
          params[:ends_on] = 12.days.from_now
        }

        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: I18n.t("api_error.invalid_starts_on")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end

  path "/projects/{project_id}/phases/{phase_id}/sprints/{id}" do
    parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"
    parameter name: :project_id, in: :path, type: :integer, description: "Project ID"
    parameter name: :phase_id, in: :path, type: :integer, description: "Phase ID"
    parameter name: :id, in: :path, type: :integer, description: "Sprint ID"
    let("Emres-Authorization") { "Bearer #{group_leader_token.token}" }
    let(:project_id) { project.id }
    let(:phase_id) { phase.id }
    let(:id) { sprint2.id }

    get "get information specific sprint" do
      tags "Sprints"
      consumes "application/json"

      response "404", "sprint not found" do
        let(:id) { 0 }

        run_test! do
          expect(response.body).to include("Couldn't find Sprint with 'id'=0")
        end
      end

      response "200", "return specific sprint" do
        let(:id) { sprint1.id }

        run_test! do
          expected = Entities::Sprint.represent sprint1, only: [:id, :name, :starts_on, :ends_on]
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "employee isn't in project cannot get information specific sprint" do
        let(:employee) { FactoryBot.create :employee }
        let(:employee_token) { FactoryBot.create :employee_token, employee: employee }
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.not_authorized_error,
              message: I18n.t("api_error.unauthorized")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end

    patch "update sprint" do
      tags "Sprints"
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, description: "Sprint's name" },
          starts_on: { type: :date, description: "Starts on of sprint" },
          ends_on: { type: :date, description: "Ends on of sprint" }
        },
        required: [:name, :starts_on, :ends_on]
      }

      let(:id) { sprint2.id }

      let(:params) do
        {
          name: "sprint 3",
          starts_on: Date.current,
          ends_on: 1.day.from_now
        }
      end

      response "401", "employee cannot update sprint" do
        let(:employee) { FactoryBot.create :employee }
        let(:employee_token) { FactoryBot.create :employee_token, employee: employee }
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

      response "401", "manager in other division cannot update sprint" do
        let(:div2) { FactoryBot.create :organization, :division }
        let(:div2_manager) { FactoryBot.create :employee, organization: div2 }
        let(:div2_manager_token) { FactoryBot.create :employee_token, employee: div2_manager }
        let("Emres-Authorization") { "Bearer #{div2_manager_token.token}" }

        before { div2.update_attributes! manager_id: div2_manager.id }

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

      response "200", "manager of PO can update sprint" do
        let("Emres-Authorization") { "Bearer #{section_manager_token.token}" }
        let(:params) { { name: "sprint 3", starts_on: 4.days.from_now, ends_on: 8.days.from_now } }
        before { section.update_attributes! manager_id: section_manager.id }

        run_test! do
          expected = Entities::Sprint.represent sprint2.reload
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "PO can update sprint" do
        let(:params) { { name: "sprint 3", starts_on: 4.days.from_now, ends_on: 8.days.from_now } }

        run_test! do
          expected = Entities::Sprint.represent sprint2.reload
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "missing params" do
        before { params.delete(:name) }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.missing_params", params: "name")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "invalid date params" do
        before { params[:starts_on] = "2018-02-30" }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.invalid", params: "starts_on")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "empty params name" do
        before { params[:name] = "" }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.empty_params", params: "name")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "422", "invalid starts on after ends on" do
        let(:params) { { name: "sprint 4", starts_on: 8.days.from_now, ends_on: 5.days.from_now } }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: I18n.t("api_error.invalid_starts_on_ends_on")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "422", "invalid starts on before ends on of previous sprint" do
        let(:params) { { name: "sprint 4", starts_on: 2.days.from_now, ends_on: 8.days.from_now } }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: I18n.t("api_error.invalid_starts_on")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "422", "time sprint not in time phase" do
        let(:id) { sprint3.id }
        before { params.merge!({ starts_on: 9.days.from_now, ends_on: 23.days.from_now }) }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: I18n.t("api_error.invalid_time_sprint")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "422", "invalid ends on after starts on of next sprint" do
        let(:params) { { name: "sprint 4", starts_on: 4.days.from_now, ends_on: 10.days.from_now } }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: I18n.t("api_error.invalid_ends_on")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

    end

    delete "Delete sprint" do
      tags "Sprints"
      consumes "application/json"

      parameter name: :id, in: :path, type: :integer, description: "Sprint ID"

      response "200", "delete successfully" do
        run_test! do |response|
          expected = { message: I18n.t("delete_success") }
          expect(response.body).to eq expected.to_json
          expect { Sprint.find(id) }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      response "200", "manager of PO can delete sprint" do
        let("Emres-Authorization") { "Bearer #{section_manager_token.token}" }

        before { section.update_attributes! manager_id: section_manager.id }

        run_test! do |response|
          expected = { message: I18n.t("delete_success") }
          expect(response.body).to eq expected.to_json
          expect { Sprint.find(id) }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      response "401", "employee cannot delete sprint" do
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

      response "401", "manager of other division cannot delete sprint" do
        let("Emres-Authorization") { "Bearer #{div2_manager_token.token}" }

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

  path "/sprints/{id}/employees" do
    parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"
    parameter name: :id, in: :path, type: :integer, description: "Sprint ID"
    let("Emres-Authorization") { "Bearer #{group_leader_token.token}" }
    let(:project_id) { project.id }
    let(:phase_id) { phase.id }
    let(:id) { sprint2.id }

    get "get information specific sprint" do
      tags "Sprints"
      consumes "application/json"

      response "404", "sprint not found" do
        let(:id) { 0 }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Sprint.name, id: id)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return employee offort information specific sprint" do
        let(:id) { sprint1.id }
        let!(:effort) { FactoryBot.create :effort, sprint: sprint1, employee_level: employee_level, effort: 80 }

        run_test! do
          expected = Entities::EmployeeLevel.represent [employee_level]
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "employee isn't in project cannot get information specific sprint" do
        let(:employee) { FactoryBot.create :employee }
        let(:employee_token) { FactoryBot.create :employee_token, employee: employee }
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.not_authorized_error,
              message: I18n.t("api_error.unauthorized")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end
end
