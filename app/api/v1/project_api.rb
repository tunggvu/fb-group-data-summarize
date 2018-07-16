# frozen_string_literal: true

class V1::ProjectAPI < Grape::API
  resources :projects do
    before { authenticate! }

    desc "Return all projects"
    get do
      projects = Project.includes(:product_owner)
      present projects, with: Entities::Project
    end

    route_param :id do
      before do
        @project = Project.find params[:id]
      end

      desc "Get specific project's information"
      get do
        present @project, with: Entities::Project
      end

      desc "Updates a project"
      params do
        requires :name, type: String, allow_blank: false
        requires :product_owner_id, type: Integer, allow_blank: false
      end
      put do
        authenticate_admin_or_organization_manager! @project.product_owner.organization
        @project.update_attributes! declared(params, include_missing: false)
        present @project, with: Entities::Project
      end
    end
  end
end
