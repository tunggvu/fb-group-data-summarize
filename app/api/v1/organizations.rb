# frozen_string_literal: true

class V1::Organizations < Grape::API
  resource :organizations do
    desc "Returns all organizations"
    get do
      Organization.top_organization
    end

    desc "Returns an organization information"
    route_param :id do
      get do
        Organization.find params[:id]
      end
    end
  end
end
