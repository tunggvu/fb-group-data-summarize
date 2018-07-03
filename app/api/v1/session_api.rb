# frozen_string_literal: true

class V1::SessionAPI < Grape::API
  resources :sessions do
    desc "Login" do
      detail "Employee use email and password to login.
      Password at least 8 charcters, have 1 number and special character. Email must prefix @framgia"
    end
    params do
      requires :email, type: String, allow_blank: false, regexp: Settings.validations.email_regex
      requires :password, type: String, allow_blank: false, regexp: Settings.validations.password_regex
      optional :remember, type: Boolean
    end
    post do
      token = EmployeeToken.generate Employee.authenticate!(params[:email], params[:password]).id, params[:remember]
      present token, with: Entities::EmployeeToken
    end

    desc "Log out"
    delete do
      token = EmployeeToken.find_by token: access_token_header
      token ? token.destroy : raise(APIError::Unauthenticated)
      status :no_content
    end
  end
end
