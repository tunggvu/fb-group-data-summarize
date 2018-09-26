# frozen_string_literal: true

class V1::SprintAPI < Grape::API
  resource :projects do
    before { authenticate! }

    route_param :project_id do
      before { @project = Project.find params[:project_id] }

      resource :phases do
        route_param :phase_id do
          before { @phase = @project.phases.find params[:phase_id] }

          resource :sprints do
            desc "return all sprints"
            paginate per_page: Settings.paginate.per_page.sprint

            get do
              authorize @project, :view?
              present paginate(@phase.sprints), with: Entities::Sprint
            end

            desc "Create new sprint"
            params do
              requires :name, type: String, allow_blank: false
              requires :starts_on, type: Date, allow_blank: false
              requires :ends_on, type: Date, allow_blank: false
              optional :efforts, type: Array do
                requires :effort, type: Integer, allow_blank: false
                requires :employee_id, type: Integer, allow_blank: false
                requires :level_id, type: Integer, allow_blank: false
              end
            end
            post do
              authorize @project, :project_manager?
              save_params = declared(params)
              create_efforts_attributes_params(save_params) if save_params[:efforts].present?
              save_params[:phase_id] = @phase.id
              present @project.sprints.create!(save_params), with: Entities::SprintMember
            end

            route_param :id do
              before do
                @sprint = @phase.sprints.find params[:id]
              end

              desc "get specific sprint's information"
              get do
                authorize @project, :view?
                present @sprint, with: Entities::Sprint
              end

              desc "update sprint's information"
              params do
                requires :name, type: String, allow_blank: false
                requires :starts_on, type: Date, allow_blank: false
                requires :ends_on, type: Date, allow_blank: false
              end
              patch do
                authorize @project, :project_manager?
                @sprint.update_attributes! declared(params, include_missing: false)
                present @sprint, with: Entities::Sprint
              end

              desc "Delete a sprint"
              delete do
                authorize @project, :project_manager?
                @sprint.destroy!
                { message: I18n.t("delete_success") }
              end
            end
          end
        end
      end
    end
  end

  resource :sprints do
    before { authenticate! }

    route_param :id do
      resource :employees do
        get do
          sprint = Sprint.find params[:id]
          authorize sprint.project, :view?
          employee_lvs = sprint.employee_levels.includes(:employee, level: :skill)
          present employee_lvs, with: Entities::EmployeeLevel
        end
      end
    end
  end

  helpers do
    def create_efforts_attributes_params(params)
      employee_levels = EmployeeLevel.find_by_employee_and_level(params[:efforts])
      if (not_found_employee = params[:efforts].pluck(:employee_id) - employee_levels.pluck(:employee_id)).present?
        raise ActiveRecord::RecordNotFound.new(nil, Employee.name, nil, not_found_employee)
      end
      params[:efforts_attributes] =
        employee_levels.size.times.map do |i|
          {
            employee_level_id: employee_levels[i].id,
            effort: params[:efforts][i][:effort]
          }
        end
      params.delete(:efforts)
    end
  end
end
