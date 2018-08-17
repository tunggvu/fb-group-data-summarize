# frozen_string_literal: true

require "swagger_helper"

describe "Project API" do
  let!(:admin) { FactoryBot.create :employee, :admin }
  let(:admin_token) { FactoryBot.create :employee_token, employee: admin }
  let!(:employee) { FactoryBot.create :employee }
  let(:employee_token) { FactoryBot.create :employee_token, employee: employee }
  let!(:project) { FactoryBot.create(:project, product_owner: admin) }
  let!(:other_project) { FactoryBot.create :project, product_owner: admin }
  let(:organization) { FactoryBot.create :organization, :clan }
  let!(:manager) { FactoryBot.create :employee, organization: organization }
  let(:manager_token) { FactoryBot.create :employee_token, employee: manager }
  before { organization.update_attributes! manager_id: manager.id }

  path "/api/v1/projects" do
    parameter name: "Authorization", in: :header, type: :string
    let(:"Authorization") { "Bearer #{admin_token.token}" }

    get "All projects" do
      consumes "application/json"

      response "401", "unauthorized" do
        let(:"Authorization") { "Bearer" }
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

      response "200", "return all projects" do
        examples "application/json" => [
          {
            id: 1,
            name: "Project 1",
            logo: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMaYHrIPq6IFEZc1DyjvRznKuxCvCelfreMChjDJeRusEm0TtgHg",
            started_at: "2018-08-08T09:32:40.649+07:00",
            description: "Description of project 1",
            product_owner: {
              id: 1,
              organization_id: 1,
              name: "Employee",
              employee_code: "B120000",
              email: "employee@framgia.com",
              birthday: "1/1/2018",
              phone: "0123456789",
              avatar: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMaYHrIPq6IFEZc1DyjvRznKuxCvCelfreMChjDJeRusEm0TtgHh"
            }
          },
          {
            id: 2,
            name: "Project 2",
            logo: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMaYHrIPq6IFEZc1DyjvRznKuxCvCelfreMChjDJeRusEm0TtgHi",
            started_at: "2018-08-08T09:32:45.649+07:00",
            description: "Description of project 2",
            product_owner: {
              id: 1,
              organization_id: 1,
              name: "Employee",
              employee_code: "B120000",
              email: "employee@framgia.com",
              birthday: "1/1/2018",
              phone: "0123456789",
              avatar: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMaYHrIPq6IFEZc1DyjvRznKuxCvCelfreMChjDJeRusEm0TtgHl"
            }
          }
        ]
        run_test! do |response|
          expected = [Entities::Project.represent(project),
            Entities::Project.represent(other_project)]
            expect(response.body).to eq expected.to_json
        end
      end
    end

    post "Create a project" do
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, description: "Project name" },
          product_owner_id: { type: :integer, description: "Product owner" }
          },
        required: [:name, :product_owner_id]
      }

      response "201", "Admin can create" do
        examples "application/json" => {
          id: 2,
          name: "Project 1",
          product_owner_id: 2
        }

        let(:params) { {
          name: "Project 1",
          product_owner_id: admin.id
        } }

        run_test! do |response|
          expected = Entities::Project.represent Project.last
          expect(response.body).to eq expected.to_json
        end
      end

      response "201", "Manager can create a project" do
        let(:"Authorization") { "Bearer #{manager_token.token}" }

        examples "application/json" => {
          id: 2,
          name: "Project 1",
          product_owner_id: 2
        }

        let(:params) { {
          name: "Project 1",
          product_owner_id: admin.id
        } }

        run_test! do |response|
          expected = Entities::Project.represent Project.last
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "Employee cannot create" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }

        let(:params) {
          {
            name: "Project 1",
            product_owner_id: admin.id
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

      response "400", "missing param name" do
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: I18n.t("api_error.missing_params", params: "name")
          }
        }

        let(:params) {
          { product_owner_id: 1 }
        }
        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.missing_params", params: "name")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end

  path "/api/v1/projects/{id}" do
    parameter name: "Authorization", in: :header, type: :string
    let(:"Authorization") { "Bearer #{admin_token.token}" }

    get "Get information of specific project" do
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer
      response "200", "return a project" do
        examples "application/json" => {
          name: "Project 1",
          logo: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMaYHrIPq6IFEZc1DyjvRznKuxCvCelfreMChjDJeRusEm0TtgHl",
          description: "Description",
          creation_time: "2018-08-10T12:36:15.959+07:00",
          product_owner: {
            id: 1,
            organization_id: 1,
            name: "Employee",
            employee_code: "B120000",
            email: "employee@framgia.com",
            birthday: "1/1/2018",
            phone: "0123456789",
            avatar: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMaYHrIPq6IFEZc1DyjvRznKuxCvCelfreMChjDJeRusEm0TtgHl"
          },
          current_sprint: {
            id: 1,
            name: "sprint 1"
          },
          phases: [
          {
            id: 1,
            name: "phase 1",
            requirements: [
              {
                id: 1,
                quantity: 7,
                phase_id: 1,
                skill_level: "Middle",
                skill_name: "Ruby"
              },
              {
                id: 2,
                quantity: 2,
                phase_id: 1,
                skill_level: "Senior",
                skill_name: "Java"
              }
            ],
            sprints: [
              {
                id: 1,
                name: "sprint 1",
                starts_on: "2018-08-10",
                ends_on: "2018-08-20",
                members: [
                  {
                    id: 339,
                    effort: 80,
                    name: "Eloy Grady",
                    skill: {
                      id: 1,
                      name: "Ruby",
                      logo: "",
                      level: {
                        id: 1,
                        name: "Junior",
                        rank: 1,
                        logo: "#"
                      }
                    }
                  },
                  {
                    id: 466,
                    effort: 25,
                    name: "Graham Streich III",
                    skill: {
                      id: 1,
                      name: "Ruby",
                      logo: "",
                      level: {
                        id: 1,
                        name: "Junior",
                        rank: 1,
                        logo: "#"
                      }
                    }
                  }
                ]
              }
            ]
          }
          ]
        }

        let(:id) { project.id }
        run_test! do
          expected = Entities::ProjectDetail.represent(project)
          expect(response.body).to eq expected.to_json
        end
      end
      response "404", "project not found" do
        let(:id) { 0 }

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
              message: I18n.t("api_error.invalid_id", model: Project.name, id: id)
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end

    patch "Update an project" do
      consumes "application/json"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, description: "Project name" },
          description: { type: :string, description: "Project description" },
          product_owner_id: { type: :integer, description: "Product owner" }
          },
        required: [:name, :description, :product_owner_id]
      }
      parameter name: :id, in: :path, type: :integer

      response "200", "admin can update a project" do
        let(:id) { project.id }
        examples "application/json" => {
          id: 1,
          name: "Project 1",
          description: "Project description",
          logo: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMaYHrIPq6IFEZc1DyjvRznKuxCvCelfreMChjDJeRusEm0TtgHl",
          started_at: "2018-08-10T05:36:15.959Z",
          product_owner: {
            id: 1,
            organization_id: 1,
            name: "Employee",
            employee_code: "B120000",
            email: "employee@framgia.com",
            birthday: "1/1/2018",
            phone: "0123456789",
            avatar: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMaYHrIPq6IFEZc1DyjvRznKuxCvCelfreMChjDJeRusEm0TtgHl"
          }
        }

        let(:params) {
          { name: "Employee's Project", description: "Project description", product_owner_id: employee.id }
        }
        run_test! do |response|
          expected = project.reload
          expect(expected.name).to eq "Employee's Project"
          expect(expected.description).to eq "Project description"
          expect(expected.product_owner).to eq employee
          expect(response.body).to eq Entities::Project.represent(expected).to_json
        end
      end

      # response "200", "manager can update a project" do
      #   let(:"Authorization") { "Bearer #{manager_token.token}" }
      #   let(:id) { project.id }
      #   examples "application/json" => {
      #     id: 1,
      #     name: "Project 1",
      #     product_owner: {
      #       id: 1,
      #       organization_id: 1,
      #       name: "Employee",
      #       employee_code: "B120000",
      #       email: "employee@framgia.com",
      #       birthday: "1/1/2018",
      #       phone: "0123456789"
      #     }
      #   }

      #   let(:params) {
      #     { name: "Manager's Project", description: "Project description", product_owner_id: manager.id }
      #   }
      #   run_test! do |response|
      #     expected = project.reload
      #     expect(expected.name).to eq "Manager's Project"
      #     expect(expected.description).to eq "Project description"
      #     expect(expected.product_owner).to eq manager
      #     expect(response.body).to eq Entities::Project.represent(expected).to_json
      #   end
      # end

      # response "400", "missing params product owner" do
      #   let(:id) { project.id }
      #   examples "application/json" => {
      #     error: {
      #       code: Settings.error_formatter.http_code.validation_errors,
      #       message: I18n.t("api_error.missing_params", params: "description")
      #     }
      #   }

      #   let(:params) { { name: "Test Project" } }
      #   run_test! do |response|
      #     expected = {
      #       error: {
      #         code: Settings.error_formatter.http_code.validation_errors,
      #         message: I18n.t("api_error.missing_params", params: "description")
      #       }
      #     }
      #     expect(response.body).to eq expected.to_json
      #   end
      # end

      # response "401", "Employee cannot update" do
      #   let(:"Authorization") { "Bearer #{employee_token.token}" }
      #   let(:id) { project.id }
      #   examples "application/json" => {
      #     error: {
      #       code: Settings.error_formatter.http_code.unauthorized,
      #       message: I18n.t("api_error.unauthorized")
      #     }
      #   }

      #   let(:params) {
      #     { name: "Test Project", product_owner_id: employee.id }
      #   }
      #   run_test! do |response|
      #     expected = {
      #       error: {
      #         code: Settings.error_formatter.http_code.unauthorized,
      #         message: I18n.t("api_error.unauthorized")
      #       }
      #     }
      #     expect(response.body).to eq expected.to_json
      #   end
      # end
    end

    # delete "delete project" do
    #   consumes "application/json"
    #   parameter name: :id, in: :path, type: :integer

    #   response "200", "admin delete successfully" do
    #     let(:id) { project.id }
    #     examples "application/json" => {
    #       message: I18n.t("delete_success")
    #     }
    #     run_test! do
    #       expected = {
    #         message: I18n.t("delete_success")
    #       }
    #       expect(response.body).to eq expected.to_json
    #     end
    #   end

    #   response "200", "manager delete successfully" do
    #     let(:id) { other_project.id }
    #     examples "application/json" => {
    #       message: I18n.t("delete_success")
    #     }
    #     run_test! do
    #       expected = {
    #         message: I18n.t("delete_success")
    #       }
    #       expect(response.body).to eq expected.to_json
    #     end
    #   end

    #   response "401", "employee cannot delete project" do
    #     let(:"Authorization") { "Bearer #{employee_token.token}" }
    #     let(:id) { project.id }
    #     examples "application/json" => {
    #       error: {
    #         code: Settings.error_formatter.http_code.unauthorized,
    #         message: I18n.t("api_error.unauthorized")
    #       }
    #     }
    #     run_test! do |response|
    #       expected = {
    #         error: {
    #           code: Settings.error_formatter.http_code.unauthorized,
    #           message: I18n.t("api_error.unauthorized")
    #         }
    #       }
    #       expect(response.body).to eq expected.to_json
    #     end
    #   end
    # end
  end
end
