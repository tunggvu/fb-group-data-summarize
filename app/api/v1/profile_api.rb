# frozen_string_literal: true

class V1::ProfileAPI < Grape::API
  resource :profile do
    before { authenticate! }

    desc "Get profile information"
    get do
      present current_user, with: Entities::Profile
    end

    desc "Update current user profile"
    params do
      optional :phone, type: String, regexp: Settings.validations.phone_regex
      optional :avatar, type: String
    end
    patch do
      current_user.update_attributes! declared(params, include_missing: false)
      present current_user, with: Entities::Profile
    end

    desc "Chang chatwork mode"
    patch :change_mode do
      current_user.send("change_mode_from_#{current_user.chatwork_status}!")
      present current_user, with: Entities::ChatworkStatus
    end
  end
end
