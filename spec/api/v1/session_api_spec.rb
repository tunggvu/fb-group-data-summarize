# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Sessions" do
  let(:employee) { FactoryBot.create :employee }
  let(:session_url) { "/api/v1/session" }
  let(:employee_token) { FactoryBot.create :employee_token, employee: employee }
  ENV["SECRET_JWT"] = "-----BEGIN RSA PRIVATE KEY-----\nMIIEogIBAAKCAQEAmrESLv5aMLEDwFcyqD0SxLQQmsqB4gvF6IAebprmJUK0ZzU8\nya0t/Y2EqRjmF2Q/D9qiTAL1BDh/vUmySZaiwFVs/hsiZlSt+3W+KZEtYhRCj+4f\njlo5TkqqfDjP6s75JNcxZZdGyh5YnPm/1OOsnGULDoLz41VhOJfpUiUZmVsHmz3I\nGbsoTmUql4DREiAJ4YDmhlz4QKPfowvXqAo+2OVwfWOCXXaefAHEAp2wZMvk6xrt\nNHvjgql1QONEFQjAIe906bctHTOBCPy5XX2LhAbLOl65/GmyV1txV8MKXlEGA8PX\nhO5D2zxlz2AUcbDGO1O4D24WDIzXsKkhznZZGQIDAQABAoIBAHjNx5GDeROFaZSP\nhDP2Xe3XYRBBDWVmJEwJobpmpUx75z6iSLKG19+m4O7dTvL9inHrH8uUk5uUM82y\n+9SUGs1w6QkYT6jygFxb+wGjKnnpsIGOSH5230HQ9YrFIzoQIGkw1JatqM63HCSa\ntcCffHE2R4gxpBzo1F/J4qAP8Qnc4fkgU0RgrZTF7TcKaNII5MH4Il+2Ezgcwxhj\nhed0IS0ElI4MvdD+MrG0fEEEvLm3/mla8PX1H8iKHH1uOyFxEQAyFj4AMC5u08uC\nk6l/l+xW5EOwlOKOnBicDEKixejc7VK5SyBqT1O0XapSYGaP3Y3fBDf4dFJZJGP3\na+dIngECgYEAzdwxZ7QG6mj9GFCOIqJa4G+fLvSzUs6q0VmDH3RqtYEkL7pc3b80\nYkn9Wsf0HSrktRv1TjNy4O5U+xwG1n2AvV7P4Tp4SX/JMJiLDMWcTfFzGDvQ5z6d\nsZ2g1tvYaTx/B/bR44Febuq1GTPSQCB+btl14L+KqAHBbqKXQ/THo1ECgYEAwF5r\nSqpPpxcHQ33Uz3ef6dNgFa/Aj4F1giWRIaDBclP8EW4gVXBH2+DUYes01z2Pl4Xf\nHzrJjnxZ5ONSZDCcL7vD2U+yOSe7+Zf3te/CBW5UJr8lHpNIZe3O/LBhwNOJF81o\nQAj6DfjF9PW/wVhWjg4SK8pF2Mozt6j9wmf0l0kCgYAi+sdqV6zVKAHZn9aHDA9l\nE5J46BuQdo2QBSXCsoVvUgJUGdat10+PZAMo6dERI7i5DYchQpzCm7zU7m47BBhc\nFUA9hTHrS0tkdocqJGnq1Jw6Ae/9WyZwh9hMqg6b0yvCrq37eoARWNBs9+FCBEN3\nknv1NJba9XFo2zfY1D8YAQKBgAHaJuBOKXwrXZeJw53HwhNnRJqQ2aLIFVCOego/\n2Pz30Ap+6/LGpPp5/LGAqT6VSiekU1SipUQo8Fii061BRo+zGBykhsvEFSw/CVSI\nHW8d89N3razQsDbDBmYqcJaBsuU2xhUvwPCXf5hvMUx0REkT25ruVKPUtpDDIMZZ\nZ+J5AoGAOfqzw/tPD0L/RCIY0gVl93w50MhECU8BUTMy3A1ovSf2j8c5sFXNsgy/\nyHYGfE5zluVY1G6xOyOvjCPI4MfACwYW9ZTmK8zR6b/M9iGf+RoYxnbQ0xBmrtyO\n3PwUD4KBoyVEEFCL/UtMRxYwZALHRVZUBadgGjnT8pPxktaN01o=\n-----END RSA PRIVATE KEY-----\n"
  ENV["PUBLIC_JWT"] = "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmrESLv5aMLEDwFcyqD0S\nxLQQmsqB4gvF6IAebprmJUK0ZzU8ya0t/Y2EqRjmF2Q/D9qiTAL1BDh/vUmySZai\nwFVs/hsiZlSt+3W+KZEtYhRCj+4fjlo5TkqqfDjP6s75JNcxZZdGyh5YnPm/1OOs\nnGULDoLz41VhOJfpUiUZmVsHmz3IGbsoTmUql4DREiAJ4YDmhlz4QKPfowvXqAo+\n2OVwfWOCXXaefAHEAp2wZMvk6xrtNHvjgql1QONEFQjAIe906bctHTOBCPy5XX2L\nhAbLOl65/GmyV1txV8MKXlEGA8PXhO5D2zxlz2AUcbDGO1O4D24WDIzXsKkhznZZ\nGQIDAQAB\n-----END PUBLIC KEY-----\n"

  path "/session" do
    post "Login API" do
      tags "Session"
      consumes "application/json"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, description: "Email" },
          password: { type: :string, description: "Password" },
          remember: { type: :boolean, description: "Remember me" }
        },
        required: ["email", "password"]
      }

      response "200", "Login success with valid email/password" do
        examples "application/json": {
          token: "Your token",
          expired_at: "2018-08-31T14:33:00.048+07:00"
        }

        let(:params) { FactoryBot.attributes_for :login_request }
        before do
          employee.update_attributes email: params[:email], password: params[:password]
        end
        run_test! do |response|
          expect_http_status :ok
        end
      end

      response "400", "Login with invalid format of email" do
        examples "application/json": {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: "#{I18n.t("grape.errors.attributes.email")} #{I18n.t("grape.errors.messages.employee.email.regexp")}"
          }
        }

        let(:params) { FactoryBot.attributes_for(:login_request, email: Faker::Internet.email, password: "123456789") }
        before do
          employee.update_attributes email: params[:email], password: params[:password]
        end

        run_test! do |response|
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: "#{I18n.t("grape.errors.attributes.email")} #{I18n.t("grape.errors.messages.employee.email.regexp")}"
            }
          }
          expect_http_status :bad_request
          expect(response.body).to eq expected.to_json
        end
      end

      response "400", "Login with invalid password" do
        examples "application/json": {
          error: {
            code: Settings.error_formatter.http_code.wrong_email_password,
            message: I18n.t("api_error.wrong_email_password")
          }
        }

        let(:params) { FactoryBot.attributes_for(:login_request, password: "Aa@123456777") }

        run_test! do |response|
          expect_http_status :bad_request
        end
      end
    end

    delete "logout api" do
      tags "Session"
      consumes "application/json"
      parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"

      response "200", "with valid token" do
        examples "application/json" => {
          "Emres-Authorization": "Bearer your_token"
        }
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }
        run_test! do |response|
          expected = { message: I18n.t("log_out") }
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "with invalid token" do
        let("Emres-Authorization") { "" }
        run_test! do |response|
          expect_http_status :unauthorized
        end
      end
    end

    patch "Change Password API" do
      tags "Session"
      consumes "application/json"
      parameter name: "Emres-Authorization", in: :header, type: :string, description: "Token authorization user"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          current_password: { type: :string, description: "Current password" },
          new_password: { type: :string, description: "New password" }
        },
        required: ["current_password", "new_password"]
      }

      response "400", "new password is wrong format " do
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }
        let(:params) {
          {
            current_password: employee.password,
            new_password: "Aa123456798"
          }
        }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: "#{I18n.t("grape.errors.attributes.new_password")} #{I18n.t("grape.errors.messages.employee.password.regexp")}"
          }
        }
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: "#{I18n.t("grape.errors.attributes.new_password")} #{I18n.t("grape.errors.messages.employee.password.regexp")}"
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "401", "Unauthorized" do
        let("Emres-Authorization") { "Bearer" }
        let(:params) {
          {
            current_password: "Aa@123456",
            new_password: "Aa@123456"
          }
        }
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

      response "400", "Wrong current password" do
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }
        let(:params) {
          {
            current_password: "Aa@23450",
            new_password: "Aa@123456"
          }
        }
        examples "application/json" => {
          error: {
            code: Settings.error_formatter.http_code.validation_errors,
            message: I18n.t("api_error.wrong_current_password")
          }
        }
        run_test! do
          expected = {
            error: {
              code: Settings.error_formatter.http_code.validation_errors,
              message: I18n.t("api_error.wrong_current_password")
            }
          }
          expect(response.body).to eq expected.to_json
        end
      end

      response "200", "Change Password success with valid new password" do
        let("Emres-Authorization") { "Bearer #{employee_token.token}" }
        let(:params) {
          {
            current_password: employee.password,
            new_password: "Aa@123456798"
          }
        }
        examples "application/json" => {
          message: I18n.t("success")
        }
        run_test! do |response|
          expected = { message: I18n.t("success") }
          expect(response.body).to eq expected.to_json
        end
      end
    end
  end
end
