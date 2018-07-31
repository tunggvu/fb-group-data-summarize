# frozen_string_literal: true

require "swagger_helper"

describe "Employee API" do
  let!(:employee) { FactoryBot.create :employee }
  let(:employee_token) { FactoryBot.create :employee_token, employee: employee }
  let!(:other_employee) { FactoryBot.create :employee }
  let(:organization) { FactoryBot.create :organization }
  let(:group) { FactoryBot.create(:organization, :clan, name: "Group 1") }
  let(:employee2) { FactoryBot.create :employee, organization: group }
  let(:employee2_token) { FactoryBot.create :employee_token, employee: employee2 }

  path "/api/v1/employees" do
    parameter name: "Authorization", in: :header, type: :string
    let(:"Authorization") { "Bearer #{employee_token.token}" }

    get "Information of all employees" do
      consumes "application/json"

      response "200", "return all employee" do
        examples "application/json" =>
          [
            {
              id: 1,
              organization_id: 1,
              name: "Employee",
              employee_code: "B120000",
              email: "employee@framgia.com",
              birthday: "1/1/2018",
              phone: "0123456789",
              avatar: "#"
            }
          ]
        run_test! do |response|
          expected = [Entities::Employee.represent(employee), Entities::Employee.represent(other_employee)]
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "unauthorized" do
        let(:"Authorization") { "" }

        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.unauthorized,
            message: "unauthorized"
          }
        }
        run_test! do
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

    post "Create employee" do
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: {type: :string},
          employee_code: {type: :string},
          email: {type: :string},
          organization_id: {type: :integer},
          password: {type: :string}
        }
      }

      response "401", "create failure because current user is not manager of organization" do
        let(:params) {
          {
            name: "New employee",
            employee_code: "B123456",
            email: "new_employee@framgia.com",
            organization_id: organization.id,
            password: "Aa@123456"
          }
        }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.unauthorized,
            message: "unauthorized"
          }
        }
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.unauthorized,
              message: "unauthorized"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "201", "create success" do
        let(:"Authorization") { "Bearer #{employee2_token.token}" }
        let(:params) {
          {
            name: "New employee",
            employee_code: "B123456",
            email: "new_employee@framgia.com",
            organization_id: group.id,
            password: "Aa@123456"
          }
        }
        examples "application/json" => {
          id: 1,
          organization_id: 1,
          name: "Employee",
          employee_code: "B120000",
          email: "employee@framgia.com",
          birthday: "1/1/2018",
          phone: "0123456789",
          avatar: "#"
        }
        before do
          group.update_attributes(manager_id: employee2.id)
        end
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
            organization_id: organization.id,
            password: "Aa@123456"
          }
        }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: "email is missing"
          }
        }
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: "email is missing"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "422", "wrong params" do
        let(:"Authorization") { "Bearer #{employee2_token.token}" }
        let(:params) {
          {
            name: "New employee",
            employee_code: "B123456",
            email: "email",
            organization_id: group.id,
            password: "Aa@123456"
          }
        }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.data_operation,
            message: "Validation failed: Email is invalid"
          }
        }
        before do
          group.update_attributes(manager_id: employee2.id)
        end
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: "Validation failed: Email is invalid"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "422", "email has been taken" do
        let(:"Authorization") { "Bearer #{employee2_token.token}" }
        let(:params) {
          {
            name: "New employee",
            employee_code: "B123456",
            email: employee.email,
            organization_id: group.id,
            password: "Aa@123456"
          }
        }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.data_operation,
            message: "Validation failed: Email has already been taken"
          }
        }
        before do
          group.update_attributes(manager_id: employee2.id)
        end
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: "Validation failed: Email has already been taken"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end

  path "/api/v1/employees/{id}" do
    parameter name: "Authorization", in: :header, type: :string
    let(:"Authorization") { "Bearer #{employee_token.token}" }

    get "Get information of specific employee" do
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer

      response "200", "return one employee" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:id) { employee.id }
        examples "application/json" => {
          id: 1,
          organization_id: 1,
          name: "Employee",
          employee_code: "B120000",
          email: "employee@framgia.com",
          birthday: "1/1/2018",
          phone: "0123456789",
          avatar: "#"
        }
        run_test! do
          expected = Entities::Employee.represent employee,
            only: [:id, :organization_id, :name, :employee_code, :email, :birthday, :phone, :avatar]
          expect(response.body).to eq expected.to_json
        end
      end

      response "404", "invalid id" do
        let(:id) { 0 }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.record_not_found,
            message: "Couldn't find Employee with 'id'=0"
          }
        }
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: "Couldn't find Employee with 'id'=0"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end

    delete "delete employee" do
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer

      response "200", "delete successfully" do
        let(:"Authorization") { "Bearer #{employee2_token.token}" }
        let(:employee) { FactoryBot.create :employee, organization: group }

        let(:id) { employee.id }
        examples "application/json" => {
          message: "Delete successfully"
        }
        before do
          group.update_attributes(manager_id: employee2.id)
        end
        run_test! do
          expected = { message: "Delete successfully" }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end
end
