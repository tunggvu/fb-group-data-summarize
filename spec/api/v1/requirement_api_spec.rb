# frozen_string_literal: true

require "swagger_helper"

describe "Requirement API" do
  let(:requirement) { FactoryBot.create :requirement }
  let!(:section) { FactoryBot.create :organization, :section }
  let!(:group) { FactoryBot.create :organization, :clan, parent: section }
  let!(:group_leader) { FactoryBot.create :employee, organization: group }
  let!(:group_leader_token) { FactoryBot.create :employee_token, employee: group_leader }
  let!(:project) { FactoryBot.create :project, product_owner: group_leader }
  let!(:phase1) { FactoryBot.create :phase, project: project }
  let!(:phase2) { FactoryBot.create :phase, project: project }
  let!(:level1) { FactoryBot.create :level }
  let!(:level2) { FactoryBot.create :level }
  let!(:requirement) { FactoryBot.create :requirement, phase: phase1, level: level1 }
  path "/phases/{phase_id}/requirements" do
    parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"
    parameter name: :phase_id, in: :path, type: :integer, description: "Phase ID"
    let("Emres-Authorization") { "Bearer #{group_leader_token.token}" }
    let(:phase_id) { phase1.id }

    get "All requirement in phases of project" do
      tags "Requirements"
      consumes "application/json"

      include_examples "unauthenticated"

      response "404", "Phase not found" do
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

      response "200", "return all requirement in phase" do
        run_test! do
          expected = Entities::Requirement.represent phase1.requirements
          expect(response.body).to eq expected.to_json
        end
      end

      response "403", "employee isn't in project cannot get all requirements" do
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

    post "Create new requirement" do
      tags "Requirements"
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          level_id: { type: :integer, description: "Level ID" },
          phase_id: { type: :integer, description: "Phase ID" },
          quantity: { type: :integer, description: "Quanity" }
        },
        required: [:level_id, :phase_id, :quantity]
      }

      response "403", "employee cannot create requirement" do
        let(:employee) { FactoryBot.create :employee }
        let(:employee_token) { FactoryBot.create :employee_token, employee: employee }
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }
        let(:params) { { phase_id: phase1.id, level_id: level1.id, quantity: 5 } }

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

      response "403", "manager in other division cannot create requirement" do
        let(:div2) { FactoryBot.create :organization, :division }
        let(:div2_manager) { FactoryBot.create :employee, organization: div2 }
        let(:div2_manager_token) { FactoryBot.create :employee_token, employee: div2_manager }
        let("Emres-Authorization") { "Bearer #{div2_manager_token.token}" }
        let(:params) { { phase_id: phase1.id, level_id: level1.id, quantity: 5 } }

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

      response "201", "manager of PO can create requirement" do
        let!(:section_manager) { FactoryBot.create :employee, organization: section }
        let(:section_manager_token) { FactoryBot.create :employee_token, employee: section_manager }
        let("Emres-Authorization") { "Bearer #{section_manager_token.token}" }
        let(:params) { { phase_id: phase1.id, level_id: level1.id, quantity: 5 } }

        before { section.update_attributes! manager_id: section_manager.id }

        run_test! do
          requirement = Requirement.last
          expected = Entities::Requirement.represent(requirement)
          expect(response.body).to eq expected.to_json
        end
      end

      response "201", "PO can create requirement" do
        let(:params) { { phase_id: phase1.id, level_id: level1.id, quantity: 5 } }

        run_test! do
          requirement = Requirement.last
          expected = Entities::Requirement.represent(requirement)
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "missing params" do
        let(:params) { {} }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.missing_params", params: "level_id")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "empty params" do
        let(:params) { { level_id: "", quantity: "" } }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.empty_params", params: "level_id")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end

  path "/phases/{phase_id}/requirements/{id}" do
    parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"
    parameter name: :phase_id, in: :path, type: :integer, description: "Phase ID"
    parameter name: :id, in: :path, type: :integer, description: "Requirement ID"
    let("Emres-Authorization") { "Bearer #{group_leader_token.token}" }
    let(:phase_id) { phase1.id }

    get "specific requirement in phase" do
      tags "Requirements"
      consumes "application/json"

      let(:id) { requirement.id }

      include_examples "unauthenticated"

      response "404", "requirement not found" do
        let(:id) { 0 }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Requirement.name, id: id)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return specific requirement in phase" do
        run_test! do
          expected = Entities::Requirement.represent(requirement)
          expect(response.body).to eq expected.to_json
        end
      end

      response "403", "employee isn't in project cannot get requirement" do
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

    patch "update requirement" do
      tags"Requirements"
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          level_id: { type: :integer, description: "Level ID" },
          quantity: { type: :integer, description: "Quanity" },
        },
        required: [:phase_id, :level_id, :quantity]
      }

      let(:id) { requirement.id }

      response "403", "employee cannot update requirement" do
        let(:employee) { FactoryBot.create :employee }
        let(:employee_token) { FactoryBot.create :employee_token, employee: employee }
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }
        let(:params) { { level_id: level2.id, quantity: 6 } }

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

      response "403", "manager in other division cannot update requirement" do
        let(:div2) { FactoryBot.create :organization, :division }
        let(:div2_manager) { FactoryBot.create :employee, organization: div2 }
        let(:div2_manager_token) { FactoryBot.create :employee_token, employee: div2_manager }
        let("Emres-Authorization") { "Bearer #{div2_manager_token.token}" }
        let(:params) { { level_id: level2.id, quantity: 6 } }

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

      response "200", "manager of PO can update phase" do
        let!(:section_manager) { FactoryBot.create :employee, organization: section }
        let(:section_manager_token) { FactoryBot.create :employee_token, employee: section_manager }
        let("Emres-Authorization") { "Bearer #{section_manager_token.token}" }
        let(:params) { { level_id: level2.id, quantity: 6 } }

        before { section.update_attributes! manager_id: section_manager.id }

        run_test! do
          requirement = Requirement.find_by(phase_id: phase1.id, level_id: level2.id, quantity: 6)
          expected = Entities::Requirement.represent(requirement)
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "PO can update phase" do
        let(:params) { { level_id: level2.id, quantity: 6 } }

        run_test! do
          requirement = Requirement.find_by(phase_id: phase1.id, level_id: level2.id, quantity: 6)
          expected = Entities::Requirement.represent(requirement)
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "missing params" do
        let(:params) { {} }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.missing_params", params: "level_id")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "422", "empty params" do
        let(:params) { { level_id: "", quantity: "" } }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: I18n.t("api_error.must_exist", model: Level.name)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end

    delete "delete requirement" do
      tags "Requirements"
      consumes "application/json"

      let(:id) { requirement.id }

      response "403", "employee cannot delete requirement" do
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

      response "403", "manager in other division cannot delete requirement" do
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

      response "200", "manager of PO can delete requirement" do
        let!(:section_manager) { FactoryBot.create :employee, organization: section }
        let(:section_manager_token) { FactoryBot.create :employee_token, employee: section_manager }
        let("Emres-Authorization") { "Bearer #{section_manager_token.token}" }

        before { section.update_attributes! manager_id: section_manager.id }

        run_test! do
          expected = { message: I18n.t("delete_success") }
          expect(response.body).to eq expected.to_json
          expect { requirement.reload }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      response "200", "PO can deleted a requirement" do
        let(:id) { requirement.id }

        run_test! do
          expected = { message: I18n.t("delete_success") }
          expect(response.body).to eq expected.to_json
          expect { requirement.reload }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end
  end
end
