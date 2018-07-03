# frozen_string_literal: true

class V1::Organizations < Grape::API
  resource :organizations do
    desc "Returns all organizations"
    get do
      present Organization.top_organization, with: Entities::Organization
    end

    desc "Returns an organization information"
    route_param :id do
      get do
        present Organization.find(params[:id]), with: Entities::Organization
      end
    end
  end
end
