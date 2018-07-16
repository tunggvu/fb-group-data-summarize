# frozen_string_literal: true

class V1::OrganizationAPI < Grape::API
  resource :organizations do
    before { authenticate! }

    desc "Returns all organizations"
    get do
      present Organization.includes(:children).top_organization,
        with: Entities::Organization
    end

    desc "Creates an organization"
    params do
      requires :name, type: String, allow_blank: false
      requires :manager_id, type: Integer, allow_blank: false
      requires :level, type: Integer, allow_blank: false
      optional :parent_id, type: Integer
    end
    post do
      authenticate_admin!
      present Organization.create!(declared(params).to_h),
        with: Entities::Organization
    end

    route_param :id do
      before { @org = Organization.includes(:children).find params[:id] }

      desc "Returns an organization"
      get do
        present @org, with: Entities::Organization
      end

      desc "Updates an organization"
      params do
        requires :name, type: String, allow_blank: false
        requires :manager_id, type: Integer, allow_blank: false
        requires :level, type: Integer, allow_blank: false
        optional :parent_id, type: Integer
      end
      put do
        authenticate_admin_or_higher_team_manager_of! @org
        @org.update_attributes! declared(params, include_mising: false).to_h
        present @org, with: Entities::Organization
      end

      desc "Deletes an organization"
      delete do
        authenticate_admin!
        @org.destroy!
        { message: "Organization destroyed successfully" }
      end
    end
  end
end
