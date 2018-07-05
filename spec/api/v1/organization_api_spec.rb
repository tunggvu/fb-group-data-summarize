# frozen_string_literal: true
require "swagger_helper"

describe "Organization API" do
  let!(:division) { FactoryBot.create(:organization, :division, name: "Division 1") }
  let!(:division2) { FactoryBot.create(:organization, :division, name: "Division 2") }
  let!(:group) { FactoryBot.create(:organization, :group, parent: division2) }
  let!(:group2) { FactoryBot.create(:organization, :group, parent: division2) }

  path "/api/v1/organizations" do
    get "organization tree" do
      consumes "application/json"
      response "200", "return application tree" do
        examples "application/json" => [{
            id: 1,
            name: "Division 1",
            parent_id: nil,
            manager_id: 2,
            level: "division",
            children: [{
              id: 2,
              name: "Section 1",
              parent_id: 1,
              manager_id: 3,
              level: "section",
              children: [{
                id: 3,
                name: "Group 1",
                parent_id: 2,
                manager_id: 4,
                level: "clan",
                children: [{
                  id: 4,
                  name: "Team 1",
                  parent_id: 3,
                  manager_id: 5,
                  level: "team",
                  children: []
                }]
              }]
            }]
          },
          {
            id: 10,
            name: "Division 2",
            parent_id: nil,
            manager_id: 12,
            level: "division",
            children: []
          }]

        run_test! do |response|
          expected = [
            Entities::Organization.represent(division),
            Entities::Organization.represent(division2)
          ]
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end

  path "/api/v1/organizations/{id}" do
    get "Information of an organization" do
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer, description: "Organization ID"
      response "200", "returns the organization information" do
        examples "application/json" => {
            id: 3,
            name: "Group 1",
            parent_id: 2,
            manager_id: 4,
            level: "clan",
            children: [{
              id: 4,
              name: "Team 1",
              parent_id: 3,
              manager_id: 5,
              level: "team",
              children: []
            }]
          }

        let(:id) { division2.id }
        run_test! do |response|
          expected = Entities::Organization.represent division2, only: [:id, :name, :parent_id, :manager_id, :level, :children]
          expect(response.body).to eq expected.to_json
        end
      end

      response "404", "returns invalid id error" do
        examples "application/json" => {
            "error_code": 603,
            "errors": "Couldn't find Organization with 'id'=100"
          }

        let(:id) { 0 }
        run_test! do |response|
          expect(response_body["error_code"]).to eq 603
          expect(response_body["errors"]).to match /Couldn't find Organization/
        end
      end
    end
  end
end
