# frozen_string_literal: true

require "swagger_helper"

describe "User API" do
  let(:employee) { FactoryBot.create :employee }

  end

  path "/employees" do
    parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"
    let("Emres-Authorization") { "Bearer #{employee_token.token}" }

    get "Information of all employees" do
      tags "Employees"
      parameter name: :query, in: :query, type: :string, description: "Filter employee with name or employee code"
      parameter name: :organization_id, in: :query, type: :integer, description: "Filter employees in organization"
      parameter name: :skill_id, in: :query, type: :integer, description: "Filter employee with skill"
      parameter name: :organization_not_in, in: :query, type: :integer, description: "Filter employees not in organization"
      parameter name: "level_ids[]", in: :query, type: :array, collectionFormat: :multi, items: { type: :integer }, description: "Filter employees with multiple levels"
      parameter name: "ids[]", in: :query, type: :array, collectionFormat: :multi, items: { type: :integer }, description: "Filter employees with ids"
      parameter name: :project_id, in: :query, type: :integer, description: "Filter employees with project id"
      parameter name: :start_time, in: :query, type: :date, required: false
      parameter name: :total_effort_lt, in: :query, type: :integer, required: false
      parameter name: :total_effort_gt, in: :query, type: :integer, required: false
      parameter name: :end_time, in: :query, type: :date, required: false

      let("Emres-Authorization") { "Bearer #{admin_token.token}" }
      let(:query) {}
      let(:organization_id) {}
      let(:skill_id) {}
      let(:organization_not_in) {}
      let("level_ids[]") { [] }
      let("ids[]") { [] }
      let(:project_id) {}
      let(:start_time) {}
      let(:total_effort_lt) {}
      let(:total_effort_gt) {}
      let(:end_time) {}

      consumes "application/json"

      response "400", "empty start_time" do
        let(:end_time) { 2.days.ago }
        let(:total_effort_lt) { 25 }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.empty_params", params: "input_time")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return employees with start time, end time and nil total_effort_lt" do
        let(:start_time) { 2.days.ago }
        let(:end_time) { 2.days.from_now }

        run_test! do |response|
          expected = Entities::EmployeeEffort.represent(Employee.with_total_efforts_in_period(start_time, end_time))
          expect(JSON.parse(response.body)).to match_array JSON.parse(expected.to_json)
        end
      end

      response "200", "return empty with start time, end time and total_effort_lt" do
        let(:start_time) { 15.days.ago }
        let(:end_time) { 10.days.ago }
        let(:total_effort_lt) { 50 }

        run_test! do |response|
          expected = []
          expect(response.body).to eq expected.to_json
        end
      end

      context "with total_effort_gt" do
        let!(:total_effort_employee) { FactoryBot.create :total_effort, employee: employee, start_time: 2.days.ago, end_time: 2.days.from_now, value: 50 }
        let!(:total_effort_manager) { FactoryBot.create :total_effort, employee: manager, start_time: 2.days.ago, end_time: 2.days.from_now, value: 80 }

        response "200", "return empty with start time, end time and total_effort_gt" do
          let(:start_time) { 2.days.ago }
          let(:end_time) { 2.days.from_now }
          let(:total_effort_gt) { 90 }

          run_test! do |response|
            expected = []
            expect(response.body).to eq expected.to_json
          end
        end

        response "200", "return empty with start time, end time, total_effort_lt and total_effort_gt" do
          let(:start_time) { 10.days.ago }
          let(:end_time) { 10.days.from_now }
          let(:total_effort_gt) { 20 }
          let(:total_effort_lt) { 40 }

          run_test! do |response|
            expected = []
            expect(response.body).to eq expected.to_json
          end
        end
      end
      response "200", "will ignore all paramaters which employee cannot use and returns all employees" do
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }
        let(:start_time) { 2.days.ago }
        let(:end_time) { 2.days.from_now }
        let(:total_effort_lt) { 50 }

        run_test! do |response|
          expected = Entities::Employee.represent(Employee.all)
          expect(response_body).to match_array JSON.parse(expected.to_json)
        end
      end

      response "200", "return employees with start time, end time and total_effort_lt" do

        let(:start_time) { 2.days.ago }
        let(:end_time) { 2.days.from_now }
        let(:total_effort_lt) { 50 }

        run_test! do |response|
          expected = Entities::EmployeeEffort.represent(Employee.with_total_efforts_in_period(start_time, end_time))
          expect(JSON.parse(response.body)).to match_array JSON.parse(expected.to_json)
        end
      end

      response "200", "return employee with all params" do
        let(:query) { employee.name }
        let(:organization_id) { employee.organization_id }
        let(:skill_id) { skill.id }
        let("level_ids[]") { [level.id, level2.id] }
        let(:start_time) { 2.days.ago }
        let(:end_time) { 2.days.from_now }
        let(:total_effort_lt) { 50 }

        run_test! do |response|
          expected = Entities::EmployeeEffort.represent(Employee.where(id: employee.id).with_total_efforts_in_period(start_time, end_time))
          expect(JSON.parse(response.body)).to match_array JSON.parse(expected.to_json)
        end
      end

      response "200", "can filter by organization, not start_time and end_time" do
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }
        let(:query) { employee.name }
        let(:organization_id) { employee.organization_id }
        let(:skill_id) { skill.id }
        let("level_ids[]") { [level.id, level2.id] }
        let(:project_id) { project.id }

        run_test! do |response|
          expected = [Entities::Employee.represent(employee)]
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "will ignore all paramaters which employee cannot use and returns all employees" do
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }
        let(:query) { employee.name }
        let(:skill_id) { skill.id }
        let("level_ids[]") { [level.id, level2.id] }

        run_test! do |response|
          expected = Entities::Employee.represent(Employee.all)
          expect(response_body).to match_array JSON.parse(expected.to_json)
        end
      end

      response "200", "GL or above can filter employees by all parameters" do
        let(:query) { employee.name }
        let(:skill_id) { skill.id }

        run_test! do |response|
          expected = [Entities::Employee.represent(employee)]
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return employees with 1 param" do
        let(:query) { employee.name }

        run_test! do |response|
          expected = [Entities::Employee.represent(employee)]
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return employees with params organization_not_in" do
        let(:organization_not_in) { section.id }
        let(:section) { FactoryBot.create(:organization, :section, parent: division) }
        let(:section2) { FactoryBot.create(:organization, :section, parent: division) }
        let(:clan1) { FactoryBot.create :organization, :clan, parent: section }
        let!(:employee1) { FactoryBot.create :employee, organization: section }
        let!(:employee2) { FactoryBot.create :employee, organization: section2 }
        let!(:employee3) { FactoryBot.create :employee, organization: clan1 }

        run_test! do |response|
          expected = Entities::Employee.represent [admin, manager, employee, employee2]
          expect(response_body).to match_array JSON.parse(expected.to_json)
        end
      end

      response "200", "return employees with params ids" do
        let("ids[]") { [employee.id, manager.id] }

        run_test! do |response|
          expected = Entities::Employee.represent [employee, manager]
          expect(response_body).to match_array JSON.parse(expected.to_json)
        end
      end

      response "200", "return employees with params organization_id" do
        let(:organization_id) { division.id }

        run_test! do |response|
          expected = [
            Entities::Employee.represent(manager)
          ]
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return employees with params project_id" do
        let(:project_id) { project.id }

        run_test! do |response|
          expected = [Entities::Employee.represent(employee)]
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return empty employees" do
        let(:query) { employee.name }
        let(:skill_id) { 0 }
        let("level_ids[]") { [0] }
        let("ids[]") { [0] }
        let(:project_id) { 0 }

        run_test! do |response|
          expected = []
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return employees without any params" do

        run_test! do |response|
          expected = Entities::Employee.represent(Employee.all)
          expect(JSON.parse(response.body)).to match_array JSON.parse(expected.to_json)
        end
      end

      include_examples "unauthenticated"

      response "404", "return error when pass organization not existed to params organization_id " do
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

      response "404", "return error when pass organization not existed to params organization_not_in " do
        let(:organization_not_in) { 0 }

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
    end

    post "Create employee" do
      tags "Employees"
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          employee_code: { type: :string },
          email: { type: :string },
          organization_id: { type: :integer },
          password: { type: :string }
        }
      }

      let(:params) {
        {
          name: "New employee",
          employee_code: "B123456",
          email: "new_employee@framgia.com",
          organization_id: group.id,
          password: "Aa@123456"
        }
      }

      include_examples "unauthenticated"

      response "403", "member cannot create employee" do
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

      response "201", "admin create successfully" do
        let("Emres-Authorization") { "Bearer #{admin_token.token}" }

        run_test! do
          expected = Entities::Employee.represent Employee.last
          expect(response.body).to eq expected.to_json
        end
      end

      response "201", "manager create successfully" do
        let("Emres-Authorization") { "Bearer #{manager_token.token}" }

        run_test! do
          expected = Entities::Employee.represent Employee.last
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "missing params email" do
        let(:params) {
          {
            name: "New employee",
            employee_code: "B123456",
            organization_id: group.id,
            password: "Aa@123456"
          }
        }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.missing_params", params: I18n.t("grape.errors.attributes.email"))
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "422", "wrong params" do
        let("Emres-Authorization") { "Bearer #{manager_token.token}" }
        let(:params) {
          {
            name: "New employee",
            employee_code: "B123456",
            email: "email",
            organization_id: group.id,
            password: "Aa@123456"
          }
        }

        before do
          group.update_attributes(manager_id: manager.id)
        end
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: I18n.t("api_error.invalid_params", params: "Email")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "422", "email has been taken" do
        let("Emres-Authorization") { "Bearer #{manager_token.token}" }
        let(:params) {
          {
            name: "New employee",
            employee_code: "B123456",
            email: employee.email,
            organization_id: group.id,
            password: "Aa@123456"
          }
        }

        before do
          group.update_attributes(manager_id: manager.id)
        end
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: I18n.t("api_error.taken_params", params: "Email")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end

  path "/employees/{id}" do
    parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"
    let("Emres-Authorization") { "Bearer #{employee_token.token}" }

    get "Get information of specific employee" do
      tags "Employees"
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer, description: "Employees ID"

      let(:id) { employee.id }

      include_examples "unauthenticated"

      response "200", "return one employee" do
        run_test! do
          expected = Entities::EmployeeDetail.represent employee
          expect(response.body).to eq expected.to_json
        end
      end

      response "404", "invalid id" do
        let(:id) { 0 }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Employee.name, id: id)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end

    delete "delete employee" do
      tags "Employees"
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer, description: "Employees ID"

      let(:employee2) { FactoryBot.create :employee, organization: group }
      let(:id) { employee2.id }

      include_examples "unauthenticated"

      response "403", "member cannot delete" do
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

      response "200", "manager can delete" do
        let("Emres-Authorization") { "Bearer #{manager_token.token}" }

        run_test! do
          expected = {
            message: I18n.t("delete_success")
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "admin can delete" do
        let("Emres-Authorization") { "Bearer #{admin_token.token}" }

        run_test! do
          expected = {
            message: I18n.t("delete_success")
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end

  path "/employees/{id}/efforts" do
    parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"
    parameter name: :id, in: :path, type: :integer, description: "Id of employee"
    parameter name: :start_time, in: :query, type: :date, description: "Start time to filter"
    parameter name: :end_time, in: :query, type: :date, description: "End time to filter"
    parameter name: :skill_id, in: :query, type: :integer, required: false
    parameter name: :project_id, in: :query, type: :integer, required: false
    parameter name: :organization_id, in: :query, type: :integer, required: false

    let("Emres-Authorization") { "Bearer #{manager_token.token}" }
    let(:id) { employee.id }
    let(:start_time) {}
    let(:end_time) {}
    let(:skill_id) {}
    let(:project_id) {}
    let(:organization_id) {}

    get "Detail efforts by employee" do
      tags "Employees"
      consumes "application/json"

      include_examples "unauthenticated"

      response "404", "invalid employee's id" do
        let(:id) { 0 }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Employee.name, id: id)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "403", "user can't view detail effort of employee in other project" do
        let(:another_employee) { FactoryBot.create :employee }
        let(:another_employee_token) { FactoryBot.create :employee_token, employee: another_employee }
        let("Emres-Authorization") { "Bearer #{another_employee_token.token}" }
        let(:start_time) { 5.days.from_now }
        let(:end_time) { 10.days.from_now }

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

      response "400", "params start_time (or end_time) is empty" do
        let(:start_time) {}

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.empty_params", params: "start_time")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "params start_time (or end_time) is invalid" do
        let(:start_time) { 0 }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.invalid", params: "start_time")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return empty array when any record match with params" do
        let(:start_time) { 20.days.from_now }
        let(:end_time) { 21.days.from_now }

        run_test! do
          expected = []
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return empty array when params end_time before start_time" do
        let(:start_time) { 20.days.from_now }
        let(:end_time) { Date.current }

        run_test! do
          expected = []
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return detail effort by employee" do
        let(:start_time) { 5.days.from_now }
        let(:end_time) { 10.days.from_now }

        run_test! do
          expected = Entities::EffortDetailWithProject.represent([effort, effort2])
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return detail effort of employee with param skill_id" do
        let(:start_time) { 5.days.from_now }
        let(:end_time) { 10.days.from_now }
        let(:skill_id) { skill.id }

        run_test! do
          expected = Entities::EffortDetailWithProject.represent([effort, effort2])
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return detail effort of employee with param project_id" do
        let(:start_time) { 5.days.from_now }
        let(:end_time) { 10.days.from_now }
        let(:project_id) { project.id }

        run_test! do
          expected = Entities::EffortDetailWithProject.represent([effort, effort2])
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return detail effort of employee with param organization_id" do
        let(:start_time) { 5.days.from_now }
        let(:end_time) { 10.days.from_now }
        let(:organization_id) { organization.id }

        run_test! do
          expected = Entities::EffortDetailWithProject.represent([effort, effort2])
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end

  path "/employees/{id}/skills" do
    parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"
    let("Emres-Authorization") { "Bearer #{employee_token.token}" }

    get "get skills of employee" do
      tags "Employees"
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer, description: "Employees ID"

      let(:id) { employee.id }

      include_examples "unauthenticated"

      response "200", "return all skill of employee" do
        run_test! do
          expected = Entities::EmployeeSkill.represent(employee, employee_id: employee.id)
          expect(response.body).to eq expected.to_json
        end
      end

      response "404", "invalid id" do
        let(:id) { 0 }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Employee.name, id: id)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end

  path "/employees/{id}/requests/created" do
    parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"
    parameter name: :id, in: :path, type: :integer, description: "Employees ID"
    let("Emres-Authorization") { "Bearer #{admin_token.token}" }
    let(:id) { admin.id }

    get "device requests that created by employee" do
      tags "Employees"
      produces "application/json"

      let(:admin2) { FactoryBot.create :employee, :admin }
      let(:device) { create :device, :laptop, pic: admin2, project: project }
      let!(:request1) { create :request, :skip_validate, :pending,  device: device, project: project, request_pic: employee, requester: admin }
      let!(:request2) { create :request, :skip_validate, :approved, device: device, project: project, request_pic: employee, requester: admin }
      let!(:request3) { create :request, :skip_validate, :confirmed, device: device, project: project, request_pic: admin, requester: admin }
      let!(:request4) { create :request, :skip_validate, :approved, device: device, project: project, request_pic: employee, requester: admin2 }

      response "200", "return all device requests that created by employee" do
        run_test! do
          expected = Entities::Request.represent [request1, request2, request3]
          expect(JSON.parse(response.body)).to match_array JSON.parse(expected.to_json)
        end
      end

      include_examples "unauthenticated"

      response  "403", "unauthorized user" do
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

      response "404", "invalid employee's id" do
        let(:id) { 0 }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Employee.name, id: id)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end

  path "/employees/{id}/requests/received" do
    parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"
    parameter name: :id, in: :path, type: :integer, description: "Employees ID"
    let("Emres-Authorization") { "Bearer #{admin_token.token}" }
    let(:id) { admin.id }

    get "device requests that requested for employee" do
      tags "Employees"
      produces "application/json"

      let(:admin2) { FactoryBot.create :employee, :admin }
      let(:device) { create :device, :laptop, pic: admin2, project: project }
      let!(:request1) { create :request, :skip_validate, :pending,  device: device, project: project, request_pic: employee, requester: admin }
      let!(:request2) { create :request, :skip_validate, :approved, device: device, project: project, request_pic: employee, requester: admin }
      let!(:request3) { create :request, :skip_validate, :confirmed, device: device, project: project, request_pic: admin, requester: admin }
      let!(:request4) { create :request, :skip_validate, :approved, device: device, project: project, request_pic: employee, requester: admin2 }

      response "200", "return all device requests that requested for employee" do
        run_test! do
          expected = Entities::Request.represent [request3]
          expect(JSON.parse(response.body)).to match_array JSON.parse(expected.to_json)
        end
      end

      include_examples "unauthenticated"

      response  "403", "unauthorized user" do
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

      response "404", "invalid employee's id" do
        let(:id) { 0 }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Employee.name, id: id)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end

  path "/employees/{id}/requests/handle" do
    parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"
    parameter name: :id, in: :path, type: :integer, description: "Employees ID"
    let("Emres-Authorization") { "Bearer #{admin_token.token}" }
    let(:id) { admin.id }

    get "device requests that need handle by employee" do
      tags "Employees"
      produces "application/json"

      let(:admin2) { FactoryBot.create :employee, :admin }
      let(:project) { FactoryBot.create :project, product_owner: admin }
      let(:device) { create :device, :laptop, pic: admin2, project: project }
      let!(:request1) { create :request, :skip_validate, :pending,  device: device, project: project, request_pic: employee, requester: admin2 }
      let!(:request2) { create :request, :skip_validate, :approved, device: device, project: project, request_pic: employee, requester: admin }
      let!(:request3) { create :request, :skip_validate, :confirmed, device: device, project: project, request_pic: admin, requester: admin }
      let!(:request4) { create :request, :skip_validate, :approved, device: device, project: project, request_pic: employee, requester: admin2 }

      response "200", "return all device requests that need handle by employee" do
        run_test! do
          expected = Entities::Request.represent [request1]
          expect(JSON.parse(response.body)).to match_array JSON.parse(expected.to_json)
        end
      end

      include_examples "unauthenticated"

      response  "403", "unauthorized user" do
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

      response "404", "invalid employee's id" do
        let(:id) { 0 }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Employee.name, id: id)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end
end
