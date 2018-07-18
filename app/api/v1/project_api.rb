# frozen_string_literal: true

class V1::ProjectAPI < Grape::API
  resources :projects do
    before { authenticate! }

    desc "Return all projects"
    get do
      projects = Project.includes(:product_owner)
      present projects, with: Entities::Project
    end

    desc "Creates a project"
    params do
      requires :name, type: String, allow_blank: false
      requires :product_owner_id, type: Integer, allow_blank: false
    end
    post do
      authenticate_higher_or_equal_clan_manager!
      present Project.create!(declared(params).to_h),
        with: Entities::Project
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
        authenticate_admin_or_higher_clan_manager_of! @project.product_owner.organization
        @project.update_attributes! declared(params, include_missing: false)
        present @project, with: Entities::Project
      end

      desc "Deletes an project"
      delete do
        authenticate_admin_or_higher_clan_manager_of! @project.product_owner.organization
        @project.destroy!
        { message: "Project destroyed successfully" }
      end
    end
  end
end
