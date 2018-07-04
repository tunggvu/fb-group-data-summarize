# frozen_string_literal: true

class V1::OrganizationAPI < Grape::API
  resource :organizations do
    desc "Returns all organizations"
    get do
      present Organization.includes(:children).top_organization,
        with: Entities::Organization
    end

    desc "Returns an organization information"
    route_param :id do
      get do
        present Organization.includes(:children).find(params[:id]),
          with: Entities::Organization
      end
    end
  end
end
