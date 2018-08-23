# frozen_string_literal: true

class V1::ProjectAPI < Grape::API
  resources :projects do
    before { authenticate! }

    desc "Return all projects"
    paginate per_page: Settings.paginate.per_page.project

    get do
      projects = Project.includes(:product_owner)
      present paginate(projects), with: Entities::Project
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

      desc "Get specific project's information"
      get do
        project = Project.includes(phases: [sprints: [efforts: [employee_level: [:employee, :level]]], requirements: [level: :skill]]).find params[:id]
        authorize project, :view?
        present project, with: Entities::ProjectDetail
      end

      desc "Updates a project"
      params do
        optional :name, type: String
        optional :description, type: String
        optional :product_owner_id, type: Integer
      end
      patch do
        project = Project.find params[:id]
        authorize project, :project_manager?
        project.update_attributes! declared(params, include_missing: false)
        present project, with: Entities::Project
      end

      desc "Deletes an project"
      delete do
        project = Project.find params[:id]
        authorize project, :project_manager?
        project.destroy!
        { message: I18n.t("delete_success") }
      end
    end
  end
end
