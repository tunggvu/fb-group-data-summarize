# frozen_string_literal: true

require "swagger_helper"

describe "Skill API" do
  let!(:employee) { FactoryBot.create :employee }
  let(:employee_token) { FactoryBot.create :employee_token, employee: employee }
  let!(:admin) { FactoryBot.create :employee, is_admin: true }
  let(:admin_token) { FactoryBot.create :employee_token, employee: admin }
  let!(:skill) { FactoryBot.create :skill }
  let!(:other_skill) { FactoryBot.create :skill }
  path "/api/v1/skills" do
    parameter name: "Authorization", in: :header, type: :string
    let(:"Authorization") { "Bearer #{admin_token.token}" }

    get "Get all skills" do
      consumes "application/json"

      response "200", "return all skills" do
        examples "application/json" =>
          [
            {
              name: "Ruby",
              level: "Junior"
            },
            {
              name: "Ruby",
              level: "Senior"
            }
          ]
        run_test! do
          expected = [Entities::Skill.represent(skill), Entities::Skill.represent(other_skill)]
          expect(response.body).to eq expected.to_json
        end
      end
    end

    post "Create skill" do
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: {type: :string},
          level: {type: :string}
        }
      }

      response "401", "unauthorized admin" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:params) {
          {
            name: "Ruby on Rails",
            level: "Junior"
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

      response "201", "created successfully" do
        let(:params) {
          {
            name: "Ruby on Rails",
            level: "Junior"
          }
        }

        examples "application/json" => {
          name: "Ruby on Rails",
          level: "Senior"
        }
        run_test! do
          expected = Entities::Skill.represent Skill.last, only: [:name, :level]
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "missing params name" do
        let(:params) {
          {
            level: "Senior"
          }
        }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: "name is missing"
          }
        }
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: "name is missing"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "empty value for params[:name]" do
        let(:params) {
          {
            name: "",
            level: "Senior"
          }
        }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: "name is empty"
          }
        }
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: "name is empty"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end

  path "/api/v1/skills/{id}" do
    parameter name: "Authorization", in: :header, type: :string
    let(:"Authorization") { "Bearer #{admin_token.token}" }

    put "Update skill" do
      consumes "application/json"

      parameter name: :id, in: :path, type: :integer
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: {type: :string},
          level: {type: :string}
        }
      }

      response "404", "invalid id" do
        let(:id) { 0 }
        let(:params) {
          {
            name: "Ruby on Rails",
            level: "Junior"
          }
        }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.record_not_found,
            message: "Couldn't find Skill with 'id'=0"
          }
        }
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: "Couldn't find Skill with 'id'=0"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "update successfully" do
        let(:id) { skill.id }
        let(:params) {
          {
            name: "Ruby on Rails",
            level: "Junior"
          }
        }

        examples "application/json" => {
          name: "Ruby on Rails",
          level: "Senior"
        }
        run_test! do
          expected = Entities::Skill.represent skill.reload, only: [:name, :level]
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "missing params name" do
        let(:id) { skill.id }
        let(:params) {
          {
            level: "Senior"
          }
        }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: "name is missing"
          }
        }
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: "name is missing"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "422", "empty value for params[:name]" do
        let(:id) { skill.id }
        let(:params) {
          {
            name: "",
            level: "Senior"
          }
        }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.data_operation,
            message: "Validation failed: Name can't be blank"
          }
        }
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: "Validation failed: Name can't be blank"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end

    delete "Delete skill" do
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer

      response "200", "delete successfully" do
        let(:id) { skill.id }
        examples "application/json" => {
          name: "Ruby on Rails",
          level: "Junior"
        }
        run_test! do
          expected = Entities::Skill.represent skill, only: [:name, :level]
          expect(response.body).to eq expected.to_json
          expect { skill.reload }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end
  end
end
