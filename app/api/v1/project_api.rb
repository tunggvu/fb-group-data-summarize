# frozen_string_literal: true

class V1::ProjectAPI < Grape::API
  resources :projects do
    before { authenticate! }

    desc "Return all projects"
    paginate per_page: Settings.paginate.per_page.project

    params do
      optional :name, type: String
      optional :organization_id, type: Integer
    end
    get do
      projects = policy_scope(Project).includes(:product_owner).ransack(
        name_cont: params[:name],
        product_owner_organization_id_in: (Organization.subtree_of(params[:organization_id]).ids if params[:organization_id])
      ).result(distinct: true)
      present paginate(projects), with: Entities::Project
    end

    desc "Creates a project"
    params do
      requires :name, type: String, allow_blank: false
      requires :product_owner_id, type: Integer, allow_blank: false
      optional :starts_on, type: Date
      optional :logo, type: String
    end
    post do
      authorize :project, :executive?
      present Project.create!(declared(params).to_h),
        with: Entities::Project
    end

    route_param :id do

      desc "Get specific project's information"
      get do
        project = Project.find params[:id]
        authorize project, :view?
        project = Project.includes(phases: [sprints: [efforts: [employee_level: [:employee, :level]]], requirements: [level: :skill]]).find params[:id]
        present project, with: Entities::ProjectDetail
      end

      desc "Updates a project"
      params do
        optional :name, type: String
        optional :description, type: String
        optional :product_owner_id, type: Integer
        optional :starts_on, type: Date
        optional :logo, type: String
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

      desc "Get employees in project"
      get :employees do
        project = Project.find params[:id]
        authorize project, :view?
        present project.employees, with: Entities::Employee
      end
    end
  end
end
