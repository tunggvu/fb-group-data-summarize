# frozen_string_literal: true

require "swagger_helper"

describe "Request API" do
  let(:division) { create(:organization, :division, name: "Division 1") }
  let(:section) { create(:organization, :section, parent: division) }
  let(:product_owner) { create :employee, organization: division }
  let(:project) { create :project, product_owner: product_owner }
  let(:pic) { create :employee, organization: section }
  let(:skill) { create :skill }
  let(:level) { create :level, skill: skill }
  let(:employee_level) { create :employee_level, employee: pic, level: level }
  let(:sprint) { create :sprint, project: project, starts_on: project.starts_on, ends_on: 7.days.from_now }
  let!(:effort) { create :effort, sprint: sprint, employee_level: employee_level, effort: 80 }
  let(:device) { create :device, :laptop, pic: pic, project: project }
  let(:cf_token) { "cf_token" }
  let!(:request) { device.requests.create request_pic: pic, project: project, requester: product_owner, status: :approved }
  ENV["HOST_DOMAIN"] = "emres.framgia.vn"


  before do
    request.update confirmation_digest: Request.digest(cf_token)
  end

  path "/requests/{id}/confirm" do
    parameter name: :id, in: :path, type: :integer, description: "Request ID"
    parameter name: :confirmation_token, in: :query, type: :string, description: "Confirmation token"

    let(:id) { request.id }
    let(:confirmation_token) {}

    get "Update request's status for device assignment when user accept it" do
      tags "Requests"
      produces "application/json"

      response "200", "request has been accepted successfully" do
        let(:confirmation_token) { cf_token }

        run_test! do
          expected = Entities::Request.represent request.reload
          expect(response.body).to eq expected.to_json
          expect(request.status).to eq "confirmed"
          expect(request.confirmation_digest).to be_nil
        end
      end

      response "401", "return current request when missing query params" do
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.invalid_email_token,
              message: I18n.t("api_error.invalid_email_token")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "confirmation token is invalid or has been expired" do
        let(:confirmation_token) { "not_correct_or_expired_token" }
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.invalid_email_token,
              message: I18n.t("api_error.invalid_email_token")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end

  path "/requests/{id}/reject" do
    parameter name: :id, in: :path, type: :integer, description: "Request ID"
    parameter name: :confirmation_token, in: :query, type: :string, description: "Confirmation token"

    let(:id) { request.id }
    let(:confirmation_token) {}

    get "Update request's status for device assignment when user reject it" do
      tags "Requests"
      produces "application/json"

      response "200", "request has been rejected successfully" do
        let(:confirmation_token) { cf_token }

        run_test! do
          expected = Entities::Request.represent request.reload
          expect(response.body).to eq expected.to_json
          expect(request.status).to eq "rejected"
          expect(request.confirmation_digest).to be_nil
        end
      end

      response "401", "return current request when missing query params" do
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.invalid_email_token,
              message: I18n.t("api_error.invalid_email_token")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "confirmation token is invalid or has been expired" do
        let(:confirmation_token) { "not_correct_or_expired_token" }
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.invalid_email_token,
              message: I18n.t("api_error.invalid_email_token")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end
end
