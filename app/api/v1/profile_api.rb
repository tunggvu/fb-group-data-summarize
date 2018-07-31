# frozen_string_literal: true

class V1::ProfileAPI < Grape::API
  resource :profile do
    before { authenticate! }

    desc "Get profile information"
    get do
      # TODO: Dummy
      Dummy::GET_PROFILE
    end
  end
end
