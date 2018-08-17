# frozen_string_literal: true

require "swagger_helper"

describe "Effort API" do
  let(:div2) { create :organization, :division }
  let(:div2_manager) { create :employee, organization: div2 }
  let(:div2_manager_token) { create :employee_token, employee: div2_manager }
  let!(:section) { create :organization, :section }
  let!(:group) { create :organization, :clan, parent: section }
  let!(:group_leader) { create :employee, organization: group }
  let!(:section_manager) { create :employee, organization: section }
  let(:section_manager_token) { create :employee_token, employee: section_manager }
  let!(:group_leader_token) { create :employee_token, employee: group_leader }
  let(:employee) { create :employee }
  let(:employee_token) { create :employee_token, employee: employee }
  let!(:project) { create :project, product_owner: group_leader }
  let!(:sprint) { create :sprint, project: project }
  let!(:effort) { create :effort, sprint: sprint }
  let!(:another_effort) { create :effort, sprint: sprint }
  let!(:employee_level) { create :employee_level }
  let!(:admin) { FactoryBot.create :employee, :admin, organization: nil }
  let(:admin_token) { FactoryBot.create :employee_token, employee: admin }

  before { section.update_attributes! manager_id: section_manager.id }
  before { div2.update_attributes! manager_id: div2_manager.id }

  path "/api/v1/projects/{project_id}/sprints/{sprint_id}/efforts" do
    parameter name: "Authorization", in: :header, type: :string
    parameter name: :project_id, in: :path, type: :integer
    parameter name: :sprint_id, in: :path, type: :integer
    let(:"Authorization") { "Bearer #{group_leader_token.token}" }
    let(:project_id) { project.id }
    let(:sprint_id) { sprint.id }

    get "get effort of employee in a sprint" do
      consumes "application/json"

      response "404", "cannot find project id" do
        let(:project_id) { 0 }

        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.record_not_found,
            message: I18n.t("api_error.invalid_id", model: Project.name, id: 0)
          }
        }

        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Project.name, id: project_id)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "404", "cannot find sprint id" do
        let(:sprint_id) { 0 }

        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.record_not_found,
            message: I18n.t("api_error.invalid_id", model: Sprint.name, id: 0)
          }
        }

        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Sprint.name, id: sprint_id)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "user hasn't logged in cannot view effort" do
        let(:"Authorization") {}

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
        end
      end

      response "200", "Admin can view effort" do
        let(:"Authorization") { "Bearer #{admin_token.token}" }

        examples "application/json" => [
          {
            id: 10284,
            effort: 75,
            name: "Lexie Yost V",
            skill: {
              id: 1,
              name: "Ruby",
              logo: "#",
              level: {
                id: 1,
                name: "Junior",
                rank: 1,
                logo: "#"
              }
            }
          },
          {
            id: 10521,
            effort: 50,
            name: "Administator",
            skill: {
              id: 1,
              name: "Ruby",
              logo: "#",
              level: {
                id: 3,
                name: "Senior",
                rank: 3,
                logo: "#"
              }
            }
          }
        ]

        run_test! do |response|
          expected = [Entities::Effort.represent(effort),
            Entities::Effort.represent(another_effort)]
            expect(response.body).to eq expected.to_json
        end
      end
    end

    post "create an effort" do
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          effort: {type: :integer},
          employee_level_id: {type: :integer}
        }
      }

      response "201", "Admin can create effort" do
        let(:"Authorization") { "Bearer #{admin_token.token}" }
        let(:params) {
          {
            effort: rand(1..100),
            employee_level_id: employee_level.id
          }
        }

        examples "application/json" => {
          id: 1,
          employee_level_id: 1,
          effort: 100
        }

        run_test! do |response|
          expected = Entities::Effort.represent Effort.last
          expect(response.body).to eq expected.to_json
        end
      end

      response "201", "PO can create effort" do
        let(:params) {
          {
            effort: rand(1..100),
            employee_level_id: employee_level.id
          }
        }

        examples "application/json" => {
          id: 1,
          employee_level_id: 1,
          effort: 100
        }

        run_test! do |response|
          expected = Entities::Effort.represent Effort.last
          expect(response.body).to eq expected.to_json
        end
      end

      response "201", "manager of PO can create effort" do
        let(:"Authorization") { "Bearer #{section_manager_token.token}" }
        let(:params) {
          {
            effort: rand(1..100),
            employee_level_id: employee_level.id
          }
        }


        examples "application/json" => {
          employee_level_id: 1,
          effort: 100
        }
        run_test! do |response|
          expected = Entities::Effort.represent Effort.last
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "missing params" do
        let(:params) { {employee_level_id: 1} }

        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: I18n.t("api_error.missing_params", params: "effort")
          }
        }
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.missing_params", params: "effort")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "missing params" do
        let(:params) {
          {
            effort: "",
            employee_level_id: 1
          }
        }

        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: I18n.t("api_error.empty_params", params: "effort")
          }
        }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.empty_params", params: "effort")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "user hasn't logged in cannot create effort" do
        let(:"Authorization") {}
        let(:params) {
          {
            effort: rand(1..100),
            employee_level_id: 1
          }
        }

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
        end
      end

      response "401", "employee cannot create effort" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:params) {
          {
            effort: rand(1..100),
            employee_level_id: 1
          }
        }

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
        end
      end

      response "401", "manager in other division cannot create effort" do
        let(:"Authorization") { "Bearer #{div2_manager_token.token}" }
        let(:params) {
          {
            effort: rand(1..100),
            employee_level_id: 1
          }
        }

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

      response "422", "invalid employee level id" do
        let(:params) {
          {
            effort: rand(1..100),
            employee_level_id: 0
          }
        }

        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.data_operation,
            message: I18n.t("api_error.must_exist", model: EmployeeLevel.name.underscore.humanize)
          }
        }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: I18n.t("api_error.must_exist", model: EmployeeLevel.name.underscore.humanize)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "422", "effort is greater than 100" do
        let(:params) {
          {
            effort: 101,
            employee_level_id: employee_level.id
          }
        }

        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.data_operation,
            message: I18n.t("api_error.effort_greater")
          }
        }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: I18n.t("api_error.effort_greater")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "422", "effort is less than 0" do
        let(:params) {
          {
            effort: -1,
            employee_level_id: employee_level.id
          }
        }

        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.data_operation,
            message: I18n.t("api_error.effort_less_than_zero")
          }
        }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: I18n.t("api_error.effort_less_than_zero")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end

  path "/api/v1/projects/{project_id}/sprints/{sprint_id}/efforts/{id}" do
    parameter name: "Authorization", in: :header, type: :string
    parameter name: :project_id, in: :path, type: :integer
    parameter name: :sprint_id, in: :path, type: :integer
    parameter name: :id, in: :path, type: :integer
    let(:"Authorization") { "Bearer #{group_leader_token.token}" }
    let(:project_id) { project.id }
    let(:sprint_id) { sprint.id }
    let(:id) { effort.id }

    patch "update effort" do
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          effort: {type: :integer},
          employee_level_id: {type: :integer}
        }
      }

      response "200", "Admin can update effort" do
        let(:"Authorization") { "Bearer #{admin_token.token}" }
        let(:params) {
          {
            effort: 50,
            employee_level_id: employee_level.id
          }
        }

        examples "application/json" => {
          id: 1,
          employee_level_id: 1,
          effort: 50
        }
        run_test! do |response|
          expected = Entities::Effort.represent effort.reload
          expect(response.body).to eq expected.to_json
          expect(effort.effort).to eq 50
        end
      end

      response "200", "manager of PO can update effort" do
        let(:"Authorization") { "Bearer #{section_manager_token.token}" }
        let(:params) {
          {
            effort: 50,
            employee_level_id: employee_level.id
          }
        }

        examples "application/json" => {
          id: 1,
          employee_level_id: 1,
          effort: 50
        }
        run_test! do |response|
          expected = Entities::Effort.represent effort.reload
          expect(response.body).to eq expected.to_json
          expect(effort.effort).to eq 50
        end
      end

      response "200", "PO can update effort" do
        let(:params) {
          {
            effort: 50,
            employee_level_id: employee_level.id
          }
        }

        examples "application/json" => {
          id: 1,
          employee_level_id: 1,
          effort: 100
        }
        run_test! do |response|
          expected = Entities::Effort.represent effort.reload
          expect(response.body).to eq expected.to_json
          expect(effort.effort).to eq 50
        end
      end

      response "400", "empty params" do
        let(:params) {
          {
            effort: "" ,
            employee_level_id: 1
          }
        }

        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: I18n.t("api_error.empty_params", params: "effort")
          }
        }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.empty_params", params: "effort")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "employee cannot update effort" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:params) {
          {
            effort: rand(1..100),
            employee_level_id: 1
          }
        }

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
        end
      end

      response "401", "manager in other division cannot update effort" do
        let(:"Authorization") { "Bearer #{div2_manager_token.token}" }
        let(:params) {
          {
            effort: rand(1..100),
            employee_level_id: 1
          }
        }

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

    delete "delete effort" do
      consumes "application/json"
      let(:id) { effort.id }

      response "200", "Admin can delete an effort" do
        let(:"Authorization") { "Bearer #{admin_token.token}" }

        examples "application/json" => {
          message: I18n.t("delete_success")
        }
        run_test! do |response|
          expected = {message: I18n.t("delete_success")}
          expect(response.body).to eq expected.to_json
          expect { effort.reload }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      response "200", "PO can delete an effort " do
        examples "application/json" => {
          message: I18n.t("delete_success")
        }
        run_test! do |response|
          expected = {message: I18n.t("delete_success")}
          expect(response.body).to eq expected.to_json
          expect { effort.reload }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      response "200", "manager of PO can delete effort" do
        let(:"Authorization") { "Bearer #{section_manager_token.token}" }

        examples "application/json" => {
          message: I18n.t("delete_success")
        }
        run_test! do |response|
          expected = {message: I18n.t("delete_success")}
          expect(response.body).to eq expected.to_json
          expect { effort.reload }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      response "401", "user hasn't logged in cannot delete effort" do
        let(:"Authorization") {}

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

      response "401", "employee cannot delete an effort" do
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

      response "401", "manager of other division cannot delete an effort" do
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
