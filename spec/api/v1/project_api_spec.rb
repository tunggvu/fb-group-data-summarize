# frozen_string_literal: true

require "swagger_helper"

describe "Project API" do
  let(:admin) { FactoryBot.create :employee, :admin }
  let(:admin_token) { FactoryBot.create :employee_token, employee: admin }

  let(:section) { FactoryBot.create :organization, :section }
  let(:section_manager) { FactoryBot.create :employee, organization: section }
  let(:section_manager_token) { FactoryBot.create :employee_token, employee: section_manager }

  let(:other_section) { FactoryBot.create :organization, :section }
  let(:other_section_manager) { FactoryBot.create :employee, organization: other_section }
  let(:other_section_manager_token) { FactoryBot.create :employee_token, employee: other_section_manager }

  let(:group) { FactoryBot.create :organization, :clan, parent: section }
  let(:group_leader) { FactoryBot.create :employee, organization: group }
  let(:group_leader_token) { FactoryBot.create :employee_token, employee: group_leader }

  let(:employee) { FactoryBot.create :employee }
  let(:employee_token) { FactoryBot.create :employee_token, employee: employee }

  let!(:project) { FactoryBot.create(:project, product_owner: admin) }
  let!(:other_project) { FactoryBot.create :project, product_owner: group_leader }

  before do
    group.update_attributes! manager_id: group_leader.id
    section.update_attributes! manager_id: section_manager.id
    other_section.update_attributes! manager_id: other_section_manager.id
  end

  path "/api/v1/projects" do
    parameter name: "Authorization", in: :header, type: :string

    get "All projects" do
      tags "Projects"
      parameter name: :name, in: :query, type: :string
      parameter name: :organization_id, in: :query, type: :integer
      let(:name) {}
      let(:organization_id) {}
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

      response "200", "Admin can see all projects" do
        let(:"Authorization") { "Bearer #{admin_token.token}" }
        examples "application/json" => [
          {
            id: 1,
            name: "Project 1",
            logo: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMaYHrIPq6IFEZc1DyjvRznKuxCvCelfreMChjDJeRusEm0TtgHg",
            starts_on: "2018-08-08",
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
            starts_on: "2018-08-08",
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
          expect(JSON.parse(response.body)).to match_array JSON.parse(expected.to_json)
        end
      end

      response "200", "Manager can see all projects" do
        let(:"Authorization") { "Bearer #{group_leader_token.token}" }
        examples "application/json" => [
          {
            id: 1,
            name: "Project 1",
            logo: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMaYHrIPq6IFEZc1DyjvRznKuxCvCelfreMChjDJeRusEm0TtgHg",
            starts_on: "2018-08-08",
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
            starts_on: "2018-08-08",
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
          expect(JSON.parse(response.body)).to match_array JSON.parse(expected.to_json)
        end
      end

      response "200", "Employee can see all projects" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        examples "application/json" => [
          {
            id: 1,
            name: "Project 1",
            logo: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMaYHrIPq6IFEZc1DyjvRznKuxCvCelfreMChjDJeRusEm0TtgHg",
            starts_on: "2018-08-08",
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
            starts_on: "2018-08-08",
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
          expect(JSON.parse(response.body)).to match_array JSON.parse(expected.to_json)
        end
      end

      response "200", "return all projects without params" do
        examples "application/json" => [
          {
            id: 1,
            name: "Project 1",
            logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
            starts_on: "2018-08-08",
            description: "Description of project 1",
            product_owner: {
              id: 1,
              organization_id: 1,
              name: "Employee",
              employee_code: "B120000",
              email: "employee@framgia.com",
              birthday: "1/1/2018",
              phone: "0123456789",
              avatar: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png"
            }
          },
          {
            id: 2,
            name: "Project 2",
            logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
            starts_on: "2018-08-08",
            description: "Description of project 2",
            product_owner: {
              id: 1,
              organization_id: 1,
              name: "Employee",
              employee_code: "B120000",
              email: "employee@framgia.com",
              birthday: "1/1/2018",
              phone: "0123456789",
              avatar: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png"
            }
          }
        ]
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        run_test! do |response|
          expected = [Entities::Project.represent(project),
            Entities::Project.represent(other_project)]
            expect(JSON.parse(response.body)).to match_array JSON.parse(expected.to_json)
        end
      end

      response "200", "return projects match with params name" do
        examples "application/json" => [
          {
            id: 1,
            name: "Project 1",
            logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
            starts_on: "2018-08-08",
            description: "Description of project 1",
            product_owner: {
              id: 1,
              organization_id: 1,
              name: "Employee",
              employee_code: "B120000",
              email: "employee@framgia.com",
              birthday: "1/1/2018",
              phone: "0123456789",
              avatar: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png"
            }
          }
        ]
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:name) { project.name }
        run_test! do |response|
          expected = [Entities::Project.represent(project)]
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return projects have PO's org in organization_id + child" do
        examples "application/json" => [
          {
            id: 1,
            name: "Project 1",
            logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
            starts_on: "2018-08-08",
            description: "Description of project 1",
            product_owner: {
              id: 1,
              organization_id: 1,
              name: "Employee",
              employee_code: "B120000",
              email: "employee@framgia.com",
              birthday: "1/1/2018",
              phone: "0123456789",
              avatar: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png"
            }
          }
        ]
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:organization_id) { section.id }
        run_test! do |response|
          expected = [Entities::Project.represent(other_project)]
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "return nill when any project match name" do
        examples "application/json" => []
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:name) { "123 project_name 123" }
        let(:organization_id) { group.id }
        run_test! do |response|
          expected = []
          expect(response.body).to eq expected.to_json
        end
      end

      response "404", "return error when any project match organization_id + child" do
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.record_not_found,
            message: I18n.t("api_error.invalid_id", model: Organization.name, id: 0)
          }
        }
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:name) { project.name }
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

      response "200", "return projects match with params name and organization_id + child" do
        examples "application/json" => [
          {
            id: 1,
            name: "Project 1",
            logo: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
            starts_on: "2018-08-08",
            description: "Description of project 1",
            product_owner: {
              id: 1,
              organization_id: 1,
              name: "Employee",
              employee_code: "B120000",
              email: "employee@framgia.com",
              birthday: "1/1/2018",
              phone: "0123456789",
              avatar: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png"
            }
          }
        ]
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:name) { other_project.name }
        let(:organization_id) { group.id }
        run_test! do |response|
          expected = [Entities::Project.represent(other_project)]
          expect(response.body).to eq expected.to_json
        end
      end
    end

    post "Create a project" do
      tags "Projects"
      consumes "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, description: "Project name" },
          product_owner_id: { type: :integer, description: "Product owner" },
          starts_on: { type: :date, description: "Project start time" }
        },
        required: [:name, :product_owner_id]
      }

      response "201", "Admin can create" do
        let(:"Authorization") { "Bearer #{admin_token.token}" }
        examples "application/json": {
          id: 11,
          name: "Project 1",
          description: "Description of project 1",
          starts_on: "2018-07-12",
          logo: "/uploads/avatar.png",
          product_owner: {
            id: 1,
            organization_id: 1,
            name: "Administator",
            employee_code: "B1210000",
            email: "admin@framgia.com",
            birthday: "1/1/2018",
            phone: "0987654321",
            avatar: "/uploads/avatar.png"
          }
        }

        let(:params) { {
          name: "Project 1",
          product_owner_id: admin.id,
          starts_on: 3.days.ago
        } }

        run_test! do |response|
          expected = Entities::Project.represent Project.last
          expect(response.body).to eq expected.to_json
        end
      end

      response "201", "Manager can create a project" do
        let(:"Authorization") { "Bearer #{group_leader_token.token}" }

        examples "application/json": {
          id: 11,
          name: "Project 1",
          description: "Description of project 1",
          starts_on: "2018-07-12",
          logo: "/uploads/avatar.png",
          product_owner: {
            id: 1,
            organization_id: 1,
            name: "Administator",
            employee_code: "B1210000",
            email: "admin@framgia.com",
            birthday: "1/1/2018",
            phone: "0987654321",
            avatar: "/uploads/avatar.png"
          }
        }

        let(:params) { {
          name: "Project 1",
          product_owner_id: admin.id,
          starts_on: 3.days.ago
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
            product_owner_id: admin.id,
            starts_on: 3.days.ago
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
        let(:"Authorization") { "Bearer #{admin_token.token}" }
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

    get "Get information of specific project" do
      tags "Projects"
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer
      response "200", "Admin can see any project" do
        let(:"Authorization") { "Bearer #{admin_token.token}" }
        examples "application/json" => {
          name: "Project 1",
          logo: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMaYHrIPq6IFEZc1DyjvRznKuxCvCelfreMChjDJeRusEm0TtgHl",
          description: "Description",
          starts_on: "2018-08-10",
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

        let(:id) { other_project.id }
        run_test! do
          expected = Entities::ProjectDetail.represent(other_project)
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "Manager can see any project" do
        let(:"Authorization") { "Bearer #{group_leader_token.token}" }
        examples "application/json" => {
          name: "Project 1",
          logo: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMaYHrIPq6IFEZc1DyjvRznKuxCvCelfreMChjDJeRusEm0TtgHl",
          description: "Description",
          starts_on: "2018-08-10",
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

      response "200", "Employee can see project that employee belongs to" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:employee_level) { FactoryBot.create :employee_level, employee: employee }
        let(:sprint) { FactoryBot.create :sprint, project: project }
        let!(:effort) { FactoryBot.create :effort, employee_level: employee_level, sprint: sprint }
        examples "application/json" => {
          name: "Project 1",
          logo: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMaYHrIPq6IFEZc1DyjvRznKuxCvCelfreMChjDJeRusEm0TtgHl",
          description: "Description",
          starts_on: "2018-08-10",
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

      response "401", "Employee cannot see project that employee does not belongs to" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.unauthorized,
            message: I18n.t("api_error.unauthorized")
          }
        }

        let(:id) { other_project.id }
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

      response "404", "project not found" do
        let(:id) { 0 }
        let(:"Authorization") { "Bearer #{admin_token.token}" }
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
      tags "Projects"
      consumes "application/json"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, description: "Project name" },
          description: { type: :string, description: "Project description" },
          product_owner_id: { type: :integer, description: "Product owner" },
          starts_on: { type: :date, description: "Project start time" }
        }
      }
      parameter name: :id, in: :path, type: :integer

      response "200", "product owner can update project that product owner created" do
        let(:"Authorization") { "Bearer #{group_leader_token.token}" }
        let(:id) { other_project.id }

        examples "application/json": {
          id: 11,
          name: "Project 1",
          description: "Description of project 1",
          starts_on: "2018-07-12",
          logo: "/uploads/avatar.png",
          product_owner: {
            id: 1,
            organization_id: 1,
            name: "Administator",
            employee_code: "B1210000",
            email: "admin@framgia.com",
            birthday: "1/1/2018",
            phone: "0987654321",
            avatar: "/uploads/avatar.png"
          }
        }

        let(:params) {
          { name: "Manager's Project", description: "Project description", product_owner_id: group_leader.id }
        }
        run_test! do |response|
          expected = other_project.reload
          expect(expected.name).to eq "Manager's Project"
          expect(expected.description).to eq "Project description"
          expect(expected.product_owner).to eq group_leader
          expect(response.body).to eq Entities::Project.represent(expected).to_json
        end
      end

      response "200", "manager of product owner can update project that product owner created" do
        let(:"Authorization") { "Bearer #{section_manager_token.token}" }
        let(:id) { other_project.id }

        examples "application/json": {
          id: 11,
          name: "Project 1",
          description: "Description of project 1",
          starts_on: "2018-07-12",
          logo: "/uploads/avatar.png",
          product_owner: {
            id: 1,
            organization_id: 1,
            name: "Administator",
            employee_code: "B1210000",
            email: "admin@framgia.com",
            birthday: "1/1/2018",
            phone: "0987654321",
            avatar: "/uploads/avatar.png"
          }
        }

        let(:params) {
          { name: "Manager's Project", description: "Project description", product_owner_id: group_leader.id }
        }
        run_test! do |response|
          expected = other_project.reload
          expect(expected.name).to eq "Manager's Project"
          expect(expected.description).to eq "Project description"
          expect(expected.product_owner).to eq group_leader
          expect(response.body).to eq Entities::Project.represent(expected).to_json
        end
      end

      response "401", "manager, but not manage product owner cannot update project that product owner created" do
        let(:"Authorization") { "Bearer #{other_section_manager_token.token}" }
        let(:id) { other_project.id }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.unauthorized,
            message: I18n.t("api_error.unauthorized")
          }
        }

        let(:params) {
          { name: "Manager's Project", description: "Project description", product_owner_id: group_leader.id }
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

      response "200", "admin can update a project" do
        let(:id) { project.id }
        let(:"Authorization") { "Bearer #{admin_token.token}" }
        examples "application/json" => {
          id: 1,
          name: "Project 1",
          description: "Project description",
          logo: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMaYHrIPq6IFEZc1DyjvRznKuxCvCelfreMChjDJeRusEm0TtgHl",
          starts_on: "2018-08-10",
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

      response "401", "Employee cannot update" do
        let(:"Authorization") { "Bearer #{employee_token.token}" }
        let(:id) { project.id }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.unauthorized,
            message: I18n.t("api_error.unauthorized")
          }
        }

        let(:params) {
          { name: "Test Project", product_owner_id: employee.id }
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

    delete "Delete project" do
      tags "Projects"
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer

      response "200", "admin delete successfully" do
        let(:id) { project.id }
        let(:"Authorization") { "Bearer #{admin_token.token}" }
        examples "application/json" => {
          message: I18n.t("delete_success")
        }
        run_test! do
          expected = {
            message: I18n.t("delete_success")
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "manager delete successfully" do
        let(:id) { other_project.id }
        let(:"Authorization") { "Bearer #{group_leader_token.token}" }
        examples "application/json" => {
          message: I18n.t("delete_success")
        }
        run_test! do
          expected = {
            message: I18n.t("delete_success")
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "employee cannot delete project" do
        let(:id) { project.id }
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
    end
  end
end
