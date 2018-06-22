# frozen_string_literal: true

class V1::TestAPI < Grape::API
  resource :test_api do
    desc "Test API"
    get do
      {response: Settings.http_code.code_200}
    end
  end
end
