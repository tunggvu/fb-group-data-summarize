# frozen_string_literal: true

require "swagger_helper"

describe "Level API" do
  let!(:admin) { FactoryBot.create :employee, :admin, organization: nil }
  let(:admin_token) { FactoryBot.create :employee_token, employee: admin }
  let!(:employee) { FactoryBot.create :employee }
  let(:employee_token) { FactoryBot.create :employee_token, employee: employee }

  let(:skill) { FactoryBot.create :skill }
  let!(:level) { FactoryBot.create :level, skill: skill }
  let!(:level2) { FactoryBot.create :level, skill: skill }
  let!(:level3) { FactoryBot.create :level, skill: skill }

  path "/skills/{skill_id}/levels" do
    parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"
    parameter name: :skill_id, in: :path, type: :integer, description: "Skill ID"
    let("Emres-Authorization") { "Bearer #{admin_token.token}" }
    let(:skill_id) { skill.id }

    post "Create a new level" do
      tags "Levels"
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          rank: { type: :integer },
          logo: { type: :string },
        },
        required: [:name, :rank]
      }

      let(:params) { {
        name: "Master",
        rank: 100
      } }

      include_examples "unauthenticated"

      response "400", "missing parameter 'name'" do
        let(:params) { {
          rank: 100
        } }

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

      response "400", "empty parameter 'name'" do
        let(:params) { {
          name: "",
          rank: 100
        } }

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

      response "403", "employee cannot create level" do
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }

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

      response "404", "skill not found" do
        let(:skill_id) { 0 }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: "Couldn't find Skill with 'id'=#{skill_id}"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "422", "level name has already been taken" do
        let(:params) {
          {
            name: level.name,
            rank: 4
          }
        }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: "Validation failed: Name has already been taken"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "201", "level created" do
        run_test! do
          expected = Entities::Level.represent skill.levels.last
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end

  path "/skills/{skill_id}/levels/{id}" do
    parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"
    parameter name: :skill_id, in: :path, type: :integer, description: "Skill ID"
    parameter name: :id, in: :path, type: :integer, description: "Level ID"
    let("Emres-Authorization") { "Bearer #{admin_token.token}" }
    let(:skill_id) { skill.id }

    patch "update a level" do
      tags "Levels"
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          rank: { type: :integer },
          logo: { type: :string },
        },
        required: [:name, :rank]
      }

      let(:id) { level2.id }
      let(:params) { {
        name: "Master",
        rank: 100,
        logo: "#"
      } }

      include_examples "unauthenticated"

      response "400", "missing parameter 'name'" do
        let(:params) { {
          rank: 100
        } }

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

      response "400", "empty parameter 'name'" do
        let(:params) { {
          name: "",
          rank: 100,
        } }

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

      response "403", "employee cannot update level" do
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }

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

      response "422", "level name has already been taken" do
        let(:level_id) { level.id }
        let(:params) {
          {
            name: level.name,
            rank: 4
          }
        }

        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: "Validation failed: Name has already been taken"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "level updated" do
        run_test! do
          expected = Entities::Level.represent level2.reload
          expect(response.body).to eq expected.to_json
        end
      end
    end

    delete "delete level" do
      tags "Levels"
      consumes "application/json"
      let(:id) { level3.id }

      include_examples "unauthenticated"

      response "403", "employee cannot delete level" do
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }

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

      response "200", "deleted a level" do
        run_test! do
          expected = { message: "Delete successfully" }
          expect(response.body).to eq expected.to_json
          expect { level3.reload }.to raise_error ActiveRecord::RecordNotFound
          expect(skill.levels.count).to eq 2
        end
      end
    end
  end
end
