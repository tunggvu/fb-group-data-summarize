# frozen_string_literal: true
require "swagger_helper"

describe "Organization", type: :request do
  let(:response_json) do
    JSON.parse(response.body)
  end

  let!(:division) { create(:organization,
                           name: "Division 1",
                           level: :division,
                           manager_id: 1) }
  let!(:division2) { create(:organization,
                            name: "Division 2",
                            level: :division,
                            manager_id: 3) }

  describe "GET /organizations" do
    it "returns all organizations" do
      get "/api/v1/organizations"

      expect(response_json.count).to eq 2
      response_json.first do |response|
        expect(response["name"]).to eq "Division 1"
        expect(response["level"]).to eq "division"
        expect(response["manager_id"]).to eq 1
      end
      response_json.second do |response|
        expect(response["name"]).to eq "Division 2"
        expect(response["level"]).to eq "division"
        expect(response["manager_id"]).to eq 2
      end
    end

    context "With children organizations" do
      let!(:section) { create(:organization,
                              name: "Section 1",
                              level: :section,
                              parent_id: division2.id,
                              manager_id: 2) }
      let!(:group) { create(:organization,
                            name: "Group 1",
                            level: :clan,
                            parent_id: section.id,
                            manager_id: 4) }

      it "returns 2 top organizations" do
        get "/api/v1/organizations"
        expect(response_json.count).to eq 2
      end

      context "The first organization" do
        it "returns no children" do
          get "/api/v1/organizations"
          expect(response_json.count).to eq 2
          response_json.first do |response|
            expect(response["name"]).to eq "Division 1"
            expect(response["level"]).to eq "division"
            expect(response["manager_id"]).to eq 1
            expect(response["children"]).to be_empty
          end
        end
      end

      context "The second organization" do
        it "returns with a child" do
          get "/api/v1/organizations"
          expect(response_json.count).to eq 2
          response_json.second do |response|
            expect(response["name"]).to eq "Division 2"
            expect(response["level"]).to eq "division"
            expect(response["manager_id"]).to eq 3
            expect(response["children"].count).to eq 1
          end
          response_json.second["children"].first do |child|
            expect(child["name"]).to eq "Section 1"
            expect(child["level"]).to eq "section"
            expect(child["parent_id"]).to eq division2.id
            expect(child["manager_id"]).to eq 2
          end
        end

        context "The child" do
          it "returns with a sub-child" do
            get "/api/v1/organizations"
            expect(response_json.count).to eq 2
            response_json.second["children"].first["children"].first do |child|
              expect(child["name"]).to eq "Group 1"
              expect(child["level"]).to eq "clan"
              expect(child["parent_id"]).to eq section.id
              expect(child["manager_id"]).to eq 4
            end
          end
        end
      end
    end
  end

  describe "GET /organizations/:id" do
    let!(:section) { create(:organization,
                            name: "Section 1",
                            level: :section,
                            parent_id: division2.id,
                            manager_id: 2) }
    let!(:group) { create(:organization,
                          name: "Group 1",
                          level: :clan,
                          parent_id: section.id,
                          manager_id: 4) }

    context "Organization found" do
      context "With no children" do
        it "returns an organization" do
          get "/api/v1/organizations/#{Organization.division.first.id}"

          expect(response_json.count).to eq 8
          expect(response_json["id"]).to eq Organization.division.first.id
          expect(response_json["name"]).to eq Organization.division.first.name
          expect(response_json["level"]).to eq Organization.division.first.level
          expect(response_json["parent_id"]).to eq Organization.division.first.parent_id
          expect(response_json["manager_id"]).to eq Organization.division.first.manager_id
          expect(response_json["children"]).to be_empty
        end
      end

      context "With a child" do
        it "returns an organization" do
          get "/api/v1/organizations/#{Organization.division.second.id}"
          expect(response_json.count).to eq 8
          expect(response_json["id"]).to eq Organization.division.second.id
          expect(response_json["name"]).to eq Organization.division.second.name
          expect(response_json["level"]).to eq Organization.division.second.level
          expect(response_json["parent_id"]).to eq Organization.division.second.parent_id
          expect(response_json["manager_id"]).to eq Organization.division.second.manager_id
          expect(response_json["children"]).not_to be_empty
        end

        context "The child" do
          it "returns an organization" do
            get "/api/v1/organizations/#{Organization.division.second.id}"
            response_json["children"].first do |child|
              expect(child["name"]).to eq "Group 1"
              expect(child["level"]).to eq "clan"
              expect(child["parent_id"]).to eq section.id
              expect(child["manager_id"]).to eq 4
            end
          end
        end
      end
    end

    context "Organization not found" do
      it "returns with error code and message" do
        org_id = Organization.last.id
        Organization.last.destroy
        get "/api/v1/organizations/#{org_id}"

        expect(response.status).to eq 404
        expect(response_json["error_code"]).to eq 603
        expect(response_json["errors"]).to match(/Couldn't find Organization/)
      end
    end
  end
end
