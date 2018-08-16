# frozen_string_literal: true

require "swagger_helper"

describe "Phase API" do
  let!(:section) { FactoryBot.create :organization, :section }
  let!(:group) { FactoryBot.create :organization, :clan, parent: section }
  let!(:group_leader) { FactoryBot.create :employee, organization: group }
  let!(:group_leader_token) { FactoryBot.create :employee_token, employee: group_leader }
  let!(:project) { FactoryBot.create :project, product_owner: group_leader }
  let!(:phase1) { FactoryBot.create :phase, project: project }
  let!(:phase2) { FactoryBot.create :phase, project: project }

  before { group.update_attributes! manager_id: group_leader.id }

  path "/api/v1/projects/{project_id}/phases" do
    parameter name: "Authorization", in: :header, type: :string
    parameter name: :project_id, in: :path, type: :integer
    let(:"Authorization") { "Bearer #{group_leader_token.token}" }
    let(:project_id) { project.id }

    get "All phases in project" do
      consumes "application/json"

      response "404", "project not found" do
        let(:project_id) { 0 }

        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.record_not_found,
            message: I18n.t("api_error.invalid_id", model: "Project", id: 0)
          }
        }
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: "Project", id: project_id)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "employee not in project cannot view all phases" do
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

      response "200", "return all phases in project" do
        examples "application/json" =>
          [
            {
                id: 1,
                name: "Phase 1"
            },
            {
                id: 2,
                name: "Phase 2"
            }
          ]
        run_test! do
          expected = [Entities::Phase.represent(phase1), Entities::Phase.represent(phase2)]
          expect(response.body).to eq expected.to_json
        end
      end
    end

    post "Create new phase" do
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
        },
        required: [:name]
      }

      response "401", "employee cannot create phase" do
        let(:employee) { FactoryBot.create :employee }
        let(:employee_token) { FactoryBot.create :employee_token, employee: employee }
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:params) { { name: "phase 1" } }

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

      response "401", "manager in other division cannot create phase" do
        let(:div2) { FactoryBot.create :organization, :division }
        let(:div2_manager) { FactoryBot.create :employee, organization: div2 }
        let(:div2_manager_token) { FactoryBot.create :employee_token, employee: div2_manager }
        let(:"Authorization") { "Bearer #{div2_manager_token.token}" }
        let(:params) { { name: "phase 1" } }

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

      response "201", "manager of PO can create phase" do
        let!(:section_manager) { FactoryBot.create :employee, organization: section }
        let(:section_manager_token) { FactoryBot.create :employee_token, employee: section_manager }
        let(:"Authorization") { "Bearer #{section_manager_token.token}" }
        let(:params) { { name: "phase 1" } }

        before { section.update_attributes! manager_id: section_manager.id }

        examples "application/json" => {
          id: 1,
          name: "phase 1"
        }
        run_test! do
          expected = Entities::Phase.represent Phase.last
          expect(response.body).to eq expected.to_json
        end
      end

      response "201", "PO can create phase" do
        let(:params) { { name: "phase 1" } }

        examples "application/json" => {
          id: 1,
          name: "phase 1"
        }
        run_test! do
          expected = Entities::Phase.represent Phase.last
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "missing params" do
        let(:params) { {} }

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

      response "400", "empty params name" do
        let(:params) { { name: "" } }

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
    end
  end

  path "/api/v1/projects/{project_id}/phases/{id}" do
    parameter name: "Authorization", in: :header, type: :string
    parameter name: :project_id, in: :path, type: :integer
    parameter name: :id, in: :path, type: :integer
    let(:"Authorization") { "Bearer #{group_leader_token.token}" }
    let(:project_id) { project.id }

    get "specific phase in project" do
      consumes "application/json"

      response "404", "phase not found" do
        let(:id) { 0 }

        examples "application/json" => {
          error_code: 603,
          errors: "Couldn't find Phase with 'id'=0 [WHERE \"phases\".\"project_id\" = $1]"
        }
        run_test! do
          expect(response.body).to include("Couldn't find Phase with 'id'=0")
        end
      end

      response "200", "return specific phase in project" do
        let(:id) { phase1.id }
        examples "application/json" => {
          id: 1,
          name: "Phase 1"
        }
        run_test! do
          expected = Entities::Phase.represent phase1
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "employee isn't in project cannot view phase" do
        let(:employee) { FactoryBot.create :employee }
        let(:employee_token) { FactoryBot.create :employee_token, employee: employee }
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:id) { phase1.id }

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

    patch "update phase" do
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
        },
        required: [:name]
      }

      let(:id) { phase1.id }

      response "401", "employee cannot update phase" do
        let(:employee) { FactoryBot.create :employee }
        let(:employee_token) { FactoryBot.create :employee_token, employee: employee }
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:params) { { name: "phase 3" } }

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

      response "401", "manager in other division cannot update phase" do
        let(:div2) { FactoryBot.create :organization, :division }
        let(:div2_manager) { FactoryBot.create :employee, organization: div2 }
        let(:div2_manager_token) { FactoryBot.create :employee_token, employee: div2_manager }
        let(:"Authorization") { "Bearer #{div2_manager_token.token}" }
        let(:params) { { name: "phase 2" } }

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

      response "200", "manager of PO can update phase" do
        let!(:section_manager) { FactoryBot.create :employee, organization: section }
        let(:section_manager_token) { FactoryBot.create :employee_token, employee: section_manager }
        let(:"Authorization") { "Bearer #{section_manager_token.token}" }
        let(:params) { { name: "phase 3" } }

        before { section.update_attributes! manager_id: section_manager.id }

        examples "application/json" => {
          id: 1,
          name: "phase 3"
        }
        run_test! do
          expected = Entities::Phase.represent phase1.reload
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "PO can update phase" do
        let(:params) { { name: "phase 4" } }

        examples "application/json" => {
          id: 1,
          name: "phase 4"
        }
        run_test! do
          expected = Entities::Phase.represent phase1.reload
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "missing params" do
        let(:params) { {} }

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

      response "422", "empty params" do
        let(:params) { { name: "" } }

        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.data_operation,
            message: I18n.t("api_error.blank_params", params: "Name")
          }
        }
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: I18n.t("api_error.blank_params", params: "Name")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end

    delete "delete phase" do
      consumes "application/json"

      let(:id) { phase1.id }

      response "401", "employee cannot delete phase" do
        let(:employee) { FactoryBot.create :employee }
        let(:employee_token) { FactoryBot.create :employee_token, employee: employee }
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:params) { { name: "phase 3" } }

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

      response "401", "manager in other division cannot delete phase" do
        let(:div2) { FactoryBot.create :organization, :division }
        let(:div2_manager) { FactoryBot.create :employee, organization: div2 }
        let(:div2_manager_token) { FactoryBot.create :employee_token, employee: div2_manager }
        let(:"Authorization") { "Bearer #{div2_manager_token.token}" }
        let(:params) { { name: "phase 2" } }

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

      response "200", "manager of PO can delete phase" do
        let!(:section_manager) { FactoryBot.create :employee, organization: section }
        let(:section_manager_token) { FactoryBot.create :employee_token, employee: section_manager }
        let(:"Authorization") { "Bearer #{section_manager_token.token}" }

        before { section.update_attributes! manager_id: section_manager.id }

        examples "application/json" => {
          message: I18n.t("delete_success")
        }
        run_test! do
          expected = { message: I18n.t("delete_success") }
          expect(response.body).to eq expected.to_json
          expect { phase1.reload }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      response "200", "deleted a phase" do
        let(:id) { phase2.id }

        examples "application/json" =>  {
          message: I18n.t("delete_success")
        }

        run_test! do
          expected = { message: I18n.t("delete_success") }
          expect(response.body).to eq expected.to_json
          expect { phase2.reload }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end
  end
end
