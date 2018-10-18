#frozen_string_literal: true

class V1::EffortAPI < Grape::API
  resource :projects do
    before { authenticate! }

    route_param :project_id do
      before { @project = Project.find params[:project_id] }

      resources :sprints do
        route_param :sprint_id do
          before { @sprint = @project.sprints.find params[:sprint_id] }

          resource :efforts do
            desc "return all effort members of a sprint"
            paginate per_page: Settings.paginate.per_page.effort

            get do
              authorize @project, :view?
              present paginate(@sprint.efforts.includes(employee_level: [:employee, level: :skill])), with: Entities::Effort
            end

            desc "create an effort"
            params do
              requires :efforts, type: Array do
                requires :employee_id, type: Integer, allow_blank: false
                requires :level_id, type: Integer, allow_blank: false
                requires :effort, type: Integer, allow_blank: false
              end
            end
            post do
              authorize @project, :project_manager?
              ActiveRecord::Base.transaction do
                efforts = params[:efforts].map do |effort_params|
                  employee_level = EmployeeLevel.find_by(
                    employee_id: effort_params[:employee_id],
                    level_id: effort_params[:level_id]
                  )
                  next if employee_level.nil?
                  Effort.create!(
                    employee_level: employee_level,
                    effort: effort_params[:effort],
                    sprint: @sprint
                  )
                end
                present efforts.compact, with: Entities::Effort
              end
            end

            route_param :id do
              before do
                authorize @project, :project_manager?
                @effort = @sprint.efforts.find params[:id]
              end

              desc "update an effort"
              params do
                requires :effort, type: Integer, allow_blank: false
              end
              patch do
                @effort.update_attributes! effort: params[:effort]
                present @sprint.efforts.includes(employee_level: [:employee, level: :skill]), with: Entities::Effort
              end

              desc "delete an effort"
              delete do
                @effort.destroy!
                { message: I18n.t("delete_success") }
              end
            end
          end
        end
      end
    end
  end

  resource :efforts do
    before { authenticate! }

    desc "Get detail employee's effort durring start and end time"
    params do
      requires :employee_id, type: Integer, allow_blank: false
      requires :start_time, type: Date, allow_blank: false
      requires :end_time, type: Date, allow_blank: false
    end

    get do
      employee = Employee.find params[:employee_id]
      effort_ids = Effort.relate_to_period(params[:start_time], params[:end_time]).select(:id)
      effort_detail = employee.efforts.where(id: effort_ids)
      effort_detail.includes(sprint: :project).each { |effort| authorize effort.project, :view? }
      present effort_detail.includes(:employee_level, :sprint), with: Entities::EffortDetail
    end
  end
end
