# frozen_string_literal: true

require "swagger_helper"

describe "Skill API" do
  let!(:employee) { FactoryBot.create :employee }
  let(:employee_token) { FactoryBot.create :employee_token, employee: employee }
  let!(:admin) { FactoryBot.create :employee, :admin }
  let(:admin_token) { FactoryBot.create :employee_token, employee: admin }

  let!(:skill) { FactoryBot.create :skill }
  let!(:other_skill) { FactoryBot.create :skill }

  let!(:level) { FactoryBot.create :level, skill: skill }
  let!(:level2) { FactoryBot.create :level, skill: skill }

  path "/api/v1/skills" do
    parameter name: "Authorization", in: :header, type: :string
    let(:"Authorization") { "Bearer #{admin_token.token}" }

    get "Get all skills" do
      tags "Skills"
      consumes "application/json"

      response "401", "unauthenticated user" do
        let(:"Authorization") { "" }

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

      response "401", "unauthorized user" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }

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

      response "200", "return all skills" do
        examples "application/json" =>
        [
          {
            "id": 28523152,
            "name": "eu i",
            "logo": "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
            "levels": [
              {
                "id": 67354355,
                "name": "aliquip ",
                "logo": "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
                "rank": 45196393,
                "skill_id": 3593242
              }
            ],
          },
          {
            "id": 87853089,
            "name": "Ut ",
            "logo": "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
            "levels": [
              {
                "id": 67725294,
                "name": "ali",
                "logo": "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
                "rank": -1861221,
                "skill_id": -76872276
              },
              {
                "id": 61694819,
                "name": "off",
                "logo": "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
                "rank": -29289828,
                "skill_id": 24437180
              }
            ]
          }
        ]
        run_test! do
          expected = [Entities::Skill.represent(skill), Entities::Skill.represent(other_skill)]
          expect(response.body).to eq expected.to_json
        end
      end
    end

    post "Create skill" do
      tags "Skills"
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: {type: :string},
          logo: {type: :string},
          levels: [
              name: {type: :string},
              rank: {type: :integer},
              logo: {type: :string}
          ]
        }
      }

      response "201", "created successfully" do
        let(:params) {
          {
            name: "Ruby on Rails",
            logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
            levels: [
              {
                name: "Something",
                logo: "#",
                rank: 123
              },
              {
                name: "Something else",
                logo: "#",
                rank: 456
              }
            ]
          }
        }

        examples "application/json" => {
          id: 42814442,
          name: "volup",
          logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
          levels: [
            {
              id: 15785576,
              name: "al",
              logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
              rank: 92878607,
              skill_id: 60261939
            },
            {
              id: 4155938,
              name: "volupta",
              logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
              rank: -27562324,
              skill_id: 63219058
            }
          ]
        }
        run_test! do
          expected = Entities::Skill.represent Skill.last, only: [:id, :name, :logo, :levels]
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "missing params name" do
        let(:params) {
          {
            logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
            levels: [
              {
                name: "Something",
                logo: "#",
                rank: 123
              },
              {
                name: "Something else",
                logo: "#",
                rank: 456
              }
            ]
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

      response "400", "empty value for params[:name]" do
        let(:params) {
          {
            name: "",
            logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
            levels: [
              {
                name: "Something",
                logo: "#",
                rank: 123
              },
              {
                name: "Something else",
                logo: "#",
                rank: 456
              }
            ]
          }
        }

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

  path "/api/v1/skills/{id}" do
    parameter name: "Authorization", in: :header, type: :string
    let(:"Authorization") { "Bearer #{admin_token.token}" }

    patch "Update skill" do
      tags "Skills"
      consumes "application/json"

      parameter name: :id, in: :path, type: :integer
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: {type: :string},
          logo: {type: :string},
          levels: [
            id: {type: :integer},
            name: {type: :string},
            rank: {type: :integer},
            logo: {type: :string}
          ]
        }
      }

      response "404", "invalid id" do
        let(:id) { 0 }
        let(:params) {
          {
            name: "Ruby on Rails",
            logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
            levels: [
              {
                id: level.id,
                name: level.name,
                logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
                rank: level.rank
              },
              {
                id: level2.id,
                name: level2.name,
                logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
                rank: level2.rank
              }
            ]
          }
        }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.record_not_found,
            message: I18n.t("api_error.invalid_id", model: Skill.name, id: 0)
          }
        }
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.record_not_found,
              message: I18n.t("api_error.invalid_id", model: Skill.name, id: id)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "missing params name" do
        let(:id) { skill.id }
        let(:params) {
          {
            logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
            levels: [
              {
                id: level.id,
                name: level.name,
                logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
                rank: level.rank
              },
              {
                id: level2.id,
                name: level2.name,
                logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
                rank: level2.rank
              }
            ]
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

      response "400", "missing params[:levels][:name]" do
        let(:id) { skill.id }
        let(:params) {
          {
            name: "",
            logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
            levels: [
              {
                id: level.id,
                logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
                rank: level.rank
              },
              {
                id: level2.id,
                name: level2.name,
                logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
                rank: level2.rank
              }
            ]
          }
        }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: I18n.t("api_error.missing_params", params: "levels[0][name]")
          }
        }
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.missing_params", params: "levels[0][name]")
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
            logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
            levels: [
              {
                id: level.id,
                name: level.name,
                logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
                rank: level.rank
              },
              {
                id: level2.id,
                name: level2.name,
                logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
                rank: level2.rank
              }
            ]
          }
        }
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

      response "200", "update skill with new level successfully" do
        let(:id) { skill.id }
        let(:params) {
          {
            name: "Ruby on Rails",
            logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
            levels: [
              {
                id: level.id,
                name: level.name,
                logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
                rank: level.rank
              },
              {
                id: level2.id,
                name: level2.name,
                logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
                rank: level2.rank
              },
              {
                name: "level name",
                logo: "#",
                rank: 20
              }
            ]
          }
        }

        examples "application/json" => {
          id: 42814442,
          name: "volup",
          logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
          levels: [
            {
              id: 15785576,
              name: "al",
              logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
              rank: 92878607,
              skill_id: 60261939
            },
            {
              id: 4155938,
              name: "volupta",
              logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
              rank: 27562324,
              skill_id: 63219058
            },
            {
              id: 41538221,
              name: "level name",
              logo: "#",
              rank: 20,
              skill_id: 63219033
            }
          ]
        }
        run_test! do
          expected = Entities::Skill.represent skill.reload
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "delete levels when update skill successfully" do
        let(:id) { skill.id }
        let(:params) {
          {
            name: "Ruby on Rails",
            logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
            levels: [
              {
                id: level.id,
                name: level.name,
                logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
                rank: level.rank,
                _destroy: 1
              },
              {
                id: level2.id,
                name: level2.name,
                logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
                rank: level2.rank,
                _destroy: 1
              },
              {
                name: "Some Name",
                logo: "#",
                rank: 100
              }
            ]
          }
        }

        examples "application/json" => {
          id: 42814442,
          name: "volup",
          logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
          levels: [
            {
              id: 15785576,
              name: "al",
              logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
              rank: 92878607,
              skill_id: 60261939
            },
            {
              id: 4155938,
              name: "volupta",
              logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
              rank: -27562324,
              skill_id: 63219058
            }
          ]
        }
        run_test! do
          expected = Entities::Skill.represent skill.reload
          expect(response.body).to eq expected.to_json
          expect(skill.levels.count).to eq 1
        end
      end

      response "200", "update successfully" do
        let(:id) { skill.id }
        let(:params) {
          {
            name: "Ruby on Rails",
            logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
            levels: [
              {
                id: level.id,
                name: level.name,
                logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
                rank: level.rank
              },
              {
                id: level2.id,
                name: level2.name,
                logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
                rank: level2.rank
              }
            ]
          }
        }

        examples "application/json" => {
          id: 42814442,
          name: "volup",
          logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
          levels: [
            {
              id: 15785576,
              name: "al",
              logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
              rank: 92878607,
              skill_id: 60261939
            },
            {
              id: 4155938,
              name: "volupta",
              logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
              rank: -27562324,
              skill_id: 63219058
            }
          ]
        }
        run_test! do
          expected = Entities::Skill.represent skill.reload
          expect(response.body).to eq expected.to_json
        end
      end
    end

    delete "Delete skill" do
      tags "Skills"
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer

      response "422", "unable to delete when having association" do
        let(:id) { skill.id }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.data_operation,
            message: "Failed to destroy the record"
          }
        }

        let!(:requirement) { FactoryBot.create :requirement, level: level }
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.data_operation,
              message: "Failed to destroy the record"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "delete successfully" do
        let(:id) { skill.id }
        examples "application/json" => {
          message: I18n.t("delete_success")
        }

        run_test! do
          expected = { message: I18n.t("delete_success") }
          expect(response.body).to eq expected.to_json
          expect { skill.reload }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end
  end
end
