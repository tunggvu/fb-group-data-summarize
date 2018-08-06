# frozen_string_literal: true

class V1::ProjectAPI < Grape::API
  resources :projects do
    before { authenticate! }

    desc "Return all projects"
    get do
      projects = Project.includes(:product_owner, :phases)
      present projects, with: Entities::Project
    end

    desc "Creates a project"
    params do
      requires :name, type: String, allow_blank: false
      requires :product_owner_id, type: Integer, allow_blank: false
    end
    post do
      authorize :project, :executive?
      present Project.create!(declared(params).to_h),
        with: Entities::Project
    end

    route_param :id do
      before do
        @project = Project.find params[:id]
      end

      desc "Get specific project's information"
      get do
        # present @project, with: Entities::Project
        # TODO: Dummy
        Dummy::GET_PROJECT
      end

      desc "Updates a project"
      params do
        requires :name, type: String, allow_blank: false
        requires :product_owner_id, type: Integer, allow_blank: false
      end
      patch do
        authorize @project, :project_manager?
        @project.update_attributes! declared(params, include_missing: false)
        present @project, with: Entities::Project
      end

      desc "Deletes an project"
      delete do
        authorize @project, :project_manager?
        @project.destroy!
        { message: I18n.t("delete_success") }
      end
    end
  end
end
