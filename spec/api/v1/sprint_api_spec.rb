# frozen_string_literal: true

require "swagger_helper"

describe "SprintAPI" do
  let!(:section) { create :organization, :section }
  let!(:group) { create :organization, :clan, parent: section }
  let(:div2) { create :organization, :division }

  let(:div2_manager) { create :employee, organization: div2 }
  let(:div2_manager_token) { create :employee_token, employee: div2_manager }

  let!(:group_leader) { create :employee, organization: group }
  let!(:group_leader_token) { create :employee_token, employee: group_leader }

  let!(:section_manager) { create :employee, organization: section }
  let(:section_manager_token) { create :employee_token, employee: section_manager }

  let!(:employee) { create :employee }
  let(:employee_token) { create :employee_token, employee: employee }

  let!(:project) { create :project, product_owner: group_leader }
  let!(:phase) { create :phase, project: project }
  let!(:sprint1) { create :sprint, project: project, phase: phase }
  let!(:sprint2) { create :sprint, project: project, phase: phase }

  path "/api/v1/projects/{project_id}/phases/{phase_id}/sprints" do
    parameter name: "Authorization", in: :header, type: :string
    parameter name: :project_id, in: :path, type: :integer
    parameter name: :phase_id, in: :path, type: :integer
    let(:Authorization) { "Bearer #{group_leader_token.token}" }
    let(:project_id) { project.id }
    let(:phase_id) { phase.id }

    get "All sprint in phase" do
      consumes "application/json"

      response "404", "project not found" do
        let(:project_id) { 0 }

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
              message: I18n.t("api_error.invalid_id", model: Project.name, id: project_id)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "404", "phase not found" do
        let(:phase_id) { 0 }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.record_not_found,
            message: I18n.t("api_error.invalid_id", model: Phase.name, id: 0)
          }
        }
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
        examples "application/json" =>
          [
            {
              id: 1,
              name: "sprint 1",
              starts_on: "2018-07-19",
              ends_on: "2018-07-20"
            },
            {
              id: 2,
              name: "sprint 2",
              starts_on: "2018-07-19",
              ends_on: "2018-07-20"
            }
          ]
        run_test! do
          expected = [Entities::Sprint.represent(sprint1), Entities::Sprint.represent(sprint2)]
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "not login" do
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.unauthorized,
            message: I18n.t("api_error.unauthorized")
          }
        }
        let(:Authorization) {}
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
        let(:"Authorization") { "Bearer #{employee_token.token}" }

        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.not_authorized_error,
            message: I18n.t("api_error.unauthorized")
          }
        }
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
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: {type: :string},
          starts_on: {type: :date},
          ends_on: {type: :date},
        }
      }

      response "201", "PO can create sprint" do
        let(:params) {
          {
            name: "Sprint 1",
            starts_on: Time.now,
            ends_on: 7.days.from_now
          }
        }

        examples "application/json" => {
          id: 1,
          name: "Sprint 1",
          starts_on: "2018-07-25",
          ends_on: "2018-08-04"
        }
        run_test! do |response|
          expected = Entities::Sprint.represent Sprint.last
          expect(response.body).to eq expected.to_json
        end
      end

      response "201", "manager of PO can create sprint" do
        let(:"Authorization") { "Bearer #{section_manager_token.token}" }
        let(:params) {
          {
            name: "Sprint 1",
            starts_on: Time.now,
            ends_on: 7.days.from_now
          }
        }

        before { section.update_attributes! manager_id: section_manager.id }

        examples "application/json" => {
          id: 1,
          name: "Sprint 1",
          starts_on: "2018-07-25",
          ends_on: "2018-08-04"
        }
        run_test! do |response|
          expected = Entities::Sprint.represent Sprint.last
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "employee cannot create sprint" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:params) {
          {
            name: "Sprint 1",
            starts_on: Time.now,
            ends_on: 7.days.from_now
          }
        }

        examples "application/json" => {
          error_code: Settings.error_formatter.http_code.unauthorized,
          message: I18n.t("api_error.unauthorized")
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

      response "401", "manager in other division cannot create sprint" do
        let(:"Authorization") { "Bearer #{div2_manager_token.token}" }
        let(:params) {
          {
            name: "Sprint 1",
            starts_on: Time.now,
            ends_on: 7.days.from_now
          }
        }

        before { div2.update_attributes! manager_id: div2_manager.id }

        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.unauthorized,
            message: I18n.t("api_error.unauthorized")
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

      response "400", "empty params" do
        let(:params) {
          {
            name: "",
            starts_on: Time.now,
            ends_on: 7.days.from_now
          }
        }

        examples "application/json" => {
          error: {
            error_code: Settings.error_formatter.http_code.validation_errors,
            message: I18n.t("api_error.empty_params", params: "name")
          }
        }
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
        let(:params) {
          {
            starts_on: Time.now,
            ends_on: 7.days.from_now
          }
        }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: I18n.t("api_error.missing_params", params: "name")
          }
        }
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

      response "422", "invalid end time" do
        let(:params) {
          {
            name: "Sprint 1",
            starts_on: Time.now,
            ends_on: 7.days.ago
          }
        }

        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.data_operation,
            message: I18n.t("api_error.validate_time")
          }
        }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: I18n.t("api_error.validate_time")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end

  path "/api/v1/projects/{project_id}/phases/{phase_id}/sprints/{id}" do
    parameter name: "Authorization", in: :header, type: :string
    parameter name: :project_id, in: :path, type: :integer
    parameter name: :phase_id, in: :path, type: :integer
    parameter name: :id, in: :path, type: :integer
    let(:Authorization) { "Bearer #{group_leader_token.token}" }
    let(:project_id) { project.id }
    let(:phase_id) { phase.id }
    let(:id) { sprint1.id }

    get "get information specific sprint" do
      consumes "application/json"

      response "404", "sprint not found" do
        let(:id) { 0 }

        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.record_not_found,
            message: "Couldn't find Sprint with 'id'=0"
          }
        }
        run_test! do
          expect(response.body).to include("Couldn't find Sprint with 'id'=0")
        end
      end

      response "200", "return specific sprint" do
        let(:id) { sprint1.id }
        examples "application/json" => {
          id: 1,
          name: "sprint 1",
          starts_on: "2018-07-19",
          ends_on: "2018-07-20"
        }
        run_test! do
          expected = Entities::Sprint.represent sprint1, only: [:id, :name, :starts_on, :ends_on]
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "employee isn't in project cannot get information specific sprint" do
        let(:employee) { FactoryBot.create :employee }
        let(:employee_token) { FactoryBot.create :employee_token, employee: employee }
        let(:"Authorization") { "Bearer #{employee_token.token}" }

        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.not_authorized_error,
            message: I18n.t("api_error.unauthorized")
          }
        }

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
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          starts_on: { type: :date},
          ends_on: {type: :date}
        },
        required: [:name, :starts_on, :ends_on]
      }

      let(:id) { sprint1.id }

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
        let(:Authorization) { "Bearer #{employee_token.token}" }

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

      response "401", "manager in other division cannot update sprint" do
        let(:div2) { FactoryBot.create :organization, :division }
        let(:div2_manager) { FactoryBot.create :employee, organization: div2 }
        let(:div2_manager_token) { FactoryBot.create :employee_token, employee: div2_manager }
        let(:Authorization) { "Bearer #{div2_manager_token.token}" }

        before { div2.update_attributes! manager_id: div2_manager.id }

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

      response "200", "manager of PO can update sprint" do
        let!(:section_manager) { FactoryBot.create :employee, organization: section }
        let(:section_manager_token) { FactoryBot.create :employee_token, employee: section_manager }
        let(:Authorization) { "Bearer #{section_manager_token.token}" }

        before { section.update_attributes! manager_id: section_manager.id }

        examples "application/json" => {
          id: 1,
          name: "sprint 3",
          starts_on: "2018-07-19",
          ends_on: "2018-07-20"
        }
        run_test! do
          expected = Entities::Sprint.represent sprint1.reload
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "PO can update sprint" do
        examples "application/json" => {
          id: 1,
          name: "sprint 3",
          starts_on: "2018-07-19",
          ends_on: "2018-07-20"
        }
        run_test! do
          expected = Entities::Sprint.represent sprint1.reload
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "missing params" do
        before { params.delete(:name) }

        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: I18n.t("api_error.missing_params", params: "name")
          }
        }
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

        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: I18n.t("api_error.invalid", params: "starts_on")
          }
        }
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

        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: I18n.t("api_error.empty_params", params: "name")
          }
        }
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

      response "422", "start time is later than end time" do
        before { params.merge!({ starts_on: 2.days.from_now, ends_on: 1.day.from_now }) }

        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.data_operation,
            message: I18n.t("api_error.validate_time")
          }
        }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: I18n.t("api_error.validate_time")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end

    delete "Delete sprint" do
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer

      response "200", "delete successfully" do
        examples "appication/json" => {
          message: I18n.t("delete_success")
        }
        run_test! do |response|
          expected = { message: I18n.t("delete_success") }
          expect(response.body).to eq expected.to_json
          expect { Sprint.find(id) }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      response "200", "manager of PO can delete sprint" do
        let(:"Authorization") { "Bearer #{section_manager_token.token}" }

        before { section.update_attributes! manager_id: section_manager.id }

        examples "appication/json" => {
          message: I18n.t("delete_success")
        }
        run_test! do |response|
          expected = { message: I18n.t("delete_success") }
          expect(response.body).to eq expected.to_json
          expect { Sprint.find(id) }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      response "401", "employee cannot delete sprint" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.unauthorized,
            message: I18n.t("api_error.unauthorized")
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

      response "401", "manager of other division cannot delete sprint" do
        let(:"Authorization") { "Bearer #{div2_manager_token.token}" }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.unauthorized,
            message: I18n.t("api_error.unauthorized")
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
    end
  end
end
