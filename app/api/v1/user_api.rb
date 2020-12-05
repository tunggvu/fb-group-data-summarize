# frozen_string_literal: true

class V1::UserAPI < Grape::API
  resource :users do
    desc "Create employee"
    params do
      requires :name, type: String, allow_blank: false
      requires :email, type: String, allow_blank: false
      requires :password, type: String, allow_blank: false
      optional :birthday, type: DateTime
      optional :avatar, type: String
    end
    post do
      present User.create!(declared(params).to_h), with: Entities::User
    end

    route_param :id do
      before do
        @user = User.find params[:id]
      end

      desc "Get user's information"
      get do
        authenticate!
        present @user, with: Entities::User
      end
    end
  end
end
