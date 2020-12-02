# frozen_string_literal: true

class V1::SessionAPI < Grape::API
  resources :session do
    desc "Login"
    params do
      requires :email, type: String
      requires :password, type: String
      optional :remember, type: Boolean
    end
    post do
      status 200
      token = UserToken.generate User.authenticate!(params[:email], params[:password]).id, params[:remember]
      present token, with: Entities::UserToken
    end

    desc "Log out"
    delete do
      token = UserToken.find_by token: access_token_header
      token ? token.destroy : raise(APIError::Unauthenticated)
      { message: I18n.t("log_out") }
    end
  end
end
