# frozen_string_literal: true

require "swagger_helper"

describe "Effort API" do
  let(:div2) { create :organization, :division }
  let(:div2_manager) { create :employee, organization: div2 }
  let(:div2_manager_token) { create :employee_token, employee: div2_manager }
  let(:section) { create :organization, :section }
  let(:group) { create :organization, :clan, parent: section }
  let(:group_leader) { create :employee, organization: group }
  let(:section_manager) { create :employee, organization: section }
  let(:section_manager_token) { create :employee_token, employee: section_manager }
  let(:group_leader_token) { create :employee_token, employee: group_leader }
  let(:employee) { create :employee }
  let(:employee_token) { create :employee_token, employee: employee }
  let(:member_project) { create :employee, organization: group }
  let(:member_token) { create :employee_token, employee: member_project }
  let(:project) { create :project, product_owner: group_leader }
  let(:sprint) { create :sprint, project: project }
  let!(:effort) { create :effort, sprint: sprint }
  let(:employee_level) { create :employee_level }
  let(:employee_level_member_project) { create :employee_level, employee: member_project }
  let!(:another_effort) { create :effort, sprint: sprint, employee_level: employee_level_member_project }
  let(:admin) { FactoryBot.create :employee, :admin, organization: nil }
  let(:admin_token) { FactoryBot.create :employee_token, employee: admin }

  before { section.update_attributes! manager_id: section_manager.id }
  before { div2.update_attributes! manager_id: div2_manager.id }

  path "/projects/{project_id}/sprints/{sprint_id}/efforts" do
    parameter name: "Authorization", in: :header, type: :string, description: "Token authorization user"
    parameter name: :project_id, in: :path, type: :integer, description: "Project ID"
    parameter name: :sprint_id, in: :path, type: :integer, description: "Sprint ID"
    let(:Authorization) { "Bearer #{group_leader_token.token}" }
    let(:project_id) { project.id }
    let(:sprint_id) { sprint.id }

    get "get effort of employee in a sprint" do
      tags "Efforts"
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

      response "200", "members in project can view effort" do
        let(:"Authorization") { "Bearer #{member_token.token}" }

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

      response "401", "members not in project cannot view effort" do
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

      response "200", "PO can view effort" do
        let(:"Authorization") { "Bearer #{group_leader_token.token}" }

        examples "application/json" => [
          {
            id: 7318,
            effort: 60,
            name: "Jimmy Graham",
            skill_level: {
              level_id: 2,
              level_name: "Middle",
              logo: "#",
              rank: 2,
              skill_id: 1,
              skill_name: "Ruby"
            }
          },
          {
            id: 10284,
            effort: 75,
            name: "Lexie Yost V",
            skill_level: {
              level_id: 1,
              level_name: "Junior",
              logo: "#",
              rank: 1,
              skill_id: 1,
              skill_name: "Ruby"
            }
          }
        ]

        run_test! do |response|
          expected = [Entities::Effort.represent(effort),
            Entities::Effort.represent(another_effort)]
          expect(response.body).to eq expected.to_json
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
      tags "Efforts"
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          efforts: {
            type: :array,
            items: {
              properties: {
                employee_id: { type: :integer },
                level_id: { type: :integer },
                effort: { type: :integer }
              }
            }
          }
        },
        required: [:efforts]
      }

      let(:params) do
        {
          efforts: [
            {
              employee_id: employee_level.employee_id,
              level_id: employee_level.level_id,
              effort: rand(1..100)
            }
          ]
        }
      end

      response "201", "PO can create effort" do
        examples "application/json": [
          {
            id: 10539,
            effort: 70,
            employee_level: {
              name: "Karl White",
              id: 227,
              skill: {
                id: 1,
                name: "Ruby",
                logo: "/uploads/avatar.png",
                level: {
                  id: 3,
                  name: "Senior",
                  rank: 3,
                  logo: {
                    url: "/uploads/level/logo/3/%23"
                  }
                }
              }
            }
          }
        ]

        run_test! do |response|
          expected = [Entities::Effort.represent(Effort.last)]
          expect(response.body).to eq expected.to_json
        end
      end

      response "201", "manager of PO can create effort" do
        let(:Authorization) { "Bearer #{section_manager_token.token}" }

        examples "application/json": [
          {
            id: 10539,
            effort: 70,
            employee_level: {
              name: "Karl White",
              id: 227,
              skill: {
                id: 1,
                name: "Ruby",
                logo: "/uploads/avatar.png",
                level: {
                  id: 3,
                  name: "Senior",
                  rank: 3,
                  logo: {
                    url: "/uploads/level/logo/3/%23"
                  }
                }
              }
            }
          }
        ]

        run_test! do |response|
          expected = [Entities::Effort.represent(Effort.last)]
          expect(response.body).to eq expected.to_json
        end
      end

      response "201", "empty efforts array" do
        before { params[:efforts] = [] }

        examples "application/json": []

        run_test! do |response|
          expected = []
          expect(response.body).to eq expected.to_json
        end
      end

      response "201", "Admin can create effort" do
        let(:Authorization) { "Bearer #{admin_token.token}" }

        examples "application/json": [
          {
            id: 10539,
            effort: 70,
            employee_level: {
              name: "Karl White",
              id: 227,
              skill: {
                id: 1,
                name: "Ruby",
                logo: "/uploads/avatar.png",
                level: {
                  id: 3,
                  name: "Senior",
                  rank: 3,
                  logo: {
                    url: "/uploads/level/logo/3/%23"
                  }
                }
              }
            }
          }
        ]

        run_test! do |response|
          expected = [Entities::Effort.represent(Effort.last)]
          expect(response.body).to eq expected.to_json
        end
      end

      response "201", "skip creating effort which has invalid emp_id/level_id" do
        before { params[:efforts][0][:employee_id] = 0 }

        examples "application/json": []

        run_test! do |response|
          expected = []
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "user hasn't logged in cannot create effort" do
        let(:Authorization) { "" }

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

      response "401", "employee cannot create effort" do
        let(:Authorization) { "Bearer #{employee_token.token}" }

        examples "application/json": {
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

      response "401", "manager in other division cannot create effort" do
        let(:Authorization) { "Bearer #{div2_manager_token.token}" }

        examples "application/json": {
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

      response "400", "missing params" do
        before { params.delete(:efforts) }

        examples "application/json": {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: I18n.t("api_error.missing_params", params: :efforts)
          }
        }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.missing_params", params: :efforts)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "one of efforts missing params" do
        before { params[:efforts][0].delete(:employee_id) }

        examples "application/json": {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: I18n.t("api_error.missing_params", params: "efforts[0][employee_id]")
          }
        }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.missing_params", params: "efforts[0][employee_id]")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "422", "effort is greater than 100" do
        before { params[:efforts][0][:effort] = 101 }

        examples "application/json": {
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
        before { params[:efforts][0][:effort] = -1 }

        examples "application/json": {
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

      response "422", "duped effort" do
        let(:another_employee_level) { FactoryBot.create :employee_level, employee: employee_level.employee }

        let(:duped_effort_params) do
          {
            employee_id: another_employee_level.employee_id,
            level_id: another_employee_level.level_id,
            effort: rand(1..100)
          }
        end

        before { params[:efforts].push(duped_effort_params) }

        examples "application/json": {
          error: {
            code: Settings.error_formatter.http_code.data_operation,
            message: I18n.t("api_error.effort_employee_must_be_unique_in_sprint")
          }
        }

        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: I18n.t("api_error.effort_employee_must_be_unique_in_sprint")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end

  path "/projects/{project_id}/sprints/{sprint_id}/efforts/{id}" do
    parameter name: "Authorization", in: :header, type: :string, description: "Token authorization user"
    parameter name: :project_id, in: :path, type: :integer, description: "Project ID"
    parameter name: :sprint_id, in: :path, type: :integer, description: "Sprint ID"
    parameter name: :id, in: :path, type: :integer, description: "Effort ID"
    let(:"Authorization") { "Bearer #{group_leader_token.token}" }
    let(:project_id) { project.id }
    let(:sprint_id) { sprint.id }
    let(:id) { effort.id }

    patch "update effort" do
      tags "Efforts"
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          effort: {type: :integer}
        }
      }

      response "200", "Admin can update effort" do
        let(:"Authorization") { "Bearer #{admin_token.token}" }
        let(:params) {
          {
            effort: 50
          }
        }

        examples "application/json" => {
          id: 1,
          employee_id: 1,
          effort: 50,
          level_id: 1
        }
        run_test! do |response|
          expected = Entities::Effort.represent sprint.efforts
          expect(response.body).to eq expected.to_json
          expect(effort.reload.effort).to eq 50
        end
      end

      response "200", "manager of PO can update effort" do
        let(:"Authorization") { "Bearer #{section_manager_token.token}" }
        let(:params) {
          {
            effort: 50
          }
        }

        examples "application/json" => {
          id: 1,
          employee_level_id: 1,
          effort: 50
        }
        run_test! do |response|
          expected = Entities::Effort.represent sprint.efforts
          expect(response.body).to eq expected.to_json
          expect(effort.reload.effort).to eq 50
        end
      end

      response "200", "PO can update effort" do
        let(:params) {
          {
            effort: 50
          }
        }

        examples "application/json" => {
          id: 1,
          employee_level_id: 1,
          effort: 100
        }
        run_test! do |response|
          expected = Entities::Effort.represent sprint.efforts
          expect(response.body).to eq expected.to_json
          expect(effort.reload.effort).to eq 50
        end
      end

      response "400", "empty params" do
        let(:params) {
          {
            effort: ""
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

      response "400", "missing params" do
        let(:params) { { } }

        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: I18n.t("api_error.missing_params", params: "effort")
          }
        }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.missing_params", params: "effort")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "employee cannot update effort" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:params) {
          {
            effort: rand(1..100)
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
            effort: rand(1..100)
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
      tags "Efforts"
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

  path "/efforts" do
    parameter name: "Authorization", in: :header, type: :string, description: "Token authorization user"
    let(:Authorization) { "Bearer #{section_manager_token.token}" }

    get "Detail effort of a employee" do
      tags "Efforts"
      consumes "application/json"

      parameter name: :employee_id, in: :query, type: :integer, description: "Id of employee"
      parameter name: :start_time, in: :query, type: :string, description: "Start time to filter"
      parameter name: :end_time, in: :query, type: :string, description: "End time to filter"

      let(:employee_id) { member_project.id }
      let(:start_time) { 5.days.ago }
      let(:end_time) { 5.days.from_now }

      response "200", "return detail effort with correct params" do
        examples "application/json" =>
          [
            {
              employee_id: 1,
              start_time: "1/1/2018",
              end_time: "2/1/2018",
              effort: 100,
              sprint_id: 1,
              employee_level_id: 1
            }
          ]
        run_test! do |response|
          expected = [Entities::EffortDetail.represent(another_effort)]
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "empty params" do
        let(:end_time) {}

        examples "application/json": {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: I18n.t("api_error.empty_params", params: "end_time")
          }
        }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.empty_params", params: "end_time")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "404", "invalid employee id" do
        let(:employee_id) { 0 }

        examples "application/json": {
          error: {
            code: Settings.error_formatter.http_code.record_not_found,
            message: I18n.t("api_error.invalid_id", model: Employee.name, id: 0)
          }
        }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Employee.name, id: employee_id)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "unauthenticated" do
        let(:Authorization) {}

        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.unauthorized,
            message: I18n.t("api_error.unauthorized")
          }
        }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.unauthenticated,
              message: I18n.t("api_error.unauthorized")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "user can't view effort of employee in other project" do
        let(:Authorization) { "Bearer #{employee_token.token}" }

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
