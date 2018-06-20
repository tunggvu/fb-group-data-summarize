# frozen_string_literal: true

require "swagger_helper"

describe "TestAPI", type: :request do
  describe "test" do

    it "success" do
      get "/api/v1/test_api"
      expect(JSON.parse(response.body)["response"]).to eq 200
    end
  end
end
