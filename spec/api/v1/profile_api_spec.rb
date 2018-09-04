# frozen_string_literal: true

require "swagger_helper"

describe "Profile API" do
  let(:current_user) { FactoryBot.create(:employee) }
  let(:user_token) { FactoryBot.create :employee_token, employee: current_user }

  path "/api/v1/profile" do
    parameter name: "Authorization", in: :header, type: :string
    let(:"Authorization") { "Bearer #{user_token.token}" }

    get "Get profile information" do
      tags "Profiles"
      consumes "application/json"

      response "200", "Return profile of current user" do
        examples "application/json" => {
          id: 1,
          organization_id: 1,
          avatar: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png",
          name: "occaecat",
          employee_code: "D412437",
          email: "v8uGTMi@fAXlhkXWMQNFdsEQ.qe",
          phone: "+839948435",
          birthday: "2621-07-19"
        }
        run_test! do
          expected = Entities::Employee.represent current_user
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "Unauthenticated user" do
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.unauthorized,
            message: I18n.t("api_error.unauthorized")
          }
        }
        let(:"Authorization") { "" }
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
    end


    patch "Update current user profile" do
      tags "Profiles"
      consumes "application/json"

      parameter name: :profile, in: :body, schema: {
        type: :object,
        properties: {
          phone: { type: :string },
          avatar: { type: :string }
        }
      }

      response "200", "Updated profile" do
        examples "application/json" => {
          id: -25217952,
          organization_id: -18753403,
          name: "fugiat consectetur nulla",
          employee_code: "V612453",
          email: "Eff4Io5b-9@ILYSqeFBanInhDEINmNKeyzW.xy",
          birthday: "2436-05-01",
          phone: "43722327",
          avatar: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png"
        }
        let(:profile) {
          {
            phone: "0123456789",
            avatar: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png"
          }
        }
        run_test! do
          expected = Entities::Employee.represent current_user.reload
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "Unauthenticated user" do
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.unauthorized,
            message: I18n.t("api_error.unauthorized")
          }
        }
        let(:"Authorization") { "" }
        let(:profile) {
          {
            phone: "0123456789",
            avatar: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png"
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

      response "400", "phone is wrong format" do
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: I18n.t("api_error.invalid", params: "phone")
          }
        }
        let(:profile) {
          {
            phone: "aaa123456"
          }
        }
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.invalid", params: "phone")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end
end
