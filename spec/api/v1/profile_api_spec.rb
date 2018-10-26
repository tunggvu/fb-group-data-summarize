# frozen_string_literal: true

require "swagger_helper"

describe "Profile API" do
  let(:current_user) { FactoryBot.create(:employee) }
  let(:user_token) { FactoryBot.create :employee_token, employee: current_user }
  let(:off_user) { FactoryBot.create(:employee) }
  let(:off_user_token) { FactoryBot.create :employee_token, employee: off_user }
  let(:pending_user1) { FactoryBot.create(:employee) }
  let(:pending_user_token1) { FactoryBot.create :employee_token, employee: pending_user1 }
  let(:pending_user2) { FactoryBot.create(:employee) }
  let(:pending_user_token2) { FactoryBot.create :employee_token, employee: pending_user2 }
  let(:on_user) { FactoryBot.create(:employee) }
  let(:on_user_token) { FactoryBot.create :employee_token, employee: on_user }

  before do
    off_user.update chatwork_room_id: 1
    pending_user1.update chatwork_status: :pending
    pending_user2.update chatwork_status: :pending, chatwork_room_id: 2
    on_user.update chatwork_status: :on, chatwork_room_id: 3
  end

  path "/profile" do
    parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"
    let("Emres-Authorization") { "Bearer #{user_token.token}" }

    get "Get profile information" do
      tags "Profiles"
      consumes "application/json"

      include_examples "unauthenticated"

      response "200", "Return profile of current user" do
        run_test! do
          expected = Entities::Profile.represent current_user
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

      let(:profile) {
        {
          phone: "0123456789",
          avatar: "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png"
        }
      }

      include_examples "unauthenticated"

      response "200", "Updated profile" do
        run_test! do
          expected = Entities::Profile.represent current_user.reload
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "phone is wrong format" do
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

  path "/profile/change_mode" do
    parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"
    let("Emres-Authorization") { "Bearer #{user_token.token}" }

    patch "Change chatwork mode" do
      response "200", "From off to pending" do
        run_test! do
          expected = Entities::ChatworkStatus.represent current_user.reload
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "From off to on" do
        let("Emres-Authorization") { "Bearer #{off_user_token.token}" }
        run_test! do
          expected = Entities::ChatworkStatus.represent off_user.reload
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "From pending to off" do
        let("Emres-Authorization") { "Bearer #{pending_user_token1.token}" }
        run_test! do
          expected = Entities::ChatworkStatus.represent pending_user1.reload
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "From pending to on" do
        let("Emres-Authorization") { "Bearer #{pending_user_token2.token}" }
        run_test! do
          expected = Entities::ChatworkStatus.represent pending_user2.reload
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "From on to off" do
        let("Emres-Authorization") { "Bearer #{on_user_token.token}" }
        run_test! do
          expected = Entities::ChatworkStatus.represent on_user.reload
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end
end
