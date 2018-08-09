# frozen_string_literal: true

class V1::ProfileAPI < Grape::API
  resource :profile do
    before { authenticate! }

    desc "Get profile information"
    get do
      # TODO: Dummy
      Dummy::GET_PROFILE
    end

    desc "Update current user profile"
    params do
      optional :phone, type: String
      optional :avatar, type: String
    end
    patch do
      current_user.update_attributes! declared(params, include_missing: false)
      present current_user, with: Entities::Employee
    end
  end
end
