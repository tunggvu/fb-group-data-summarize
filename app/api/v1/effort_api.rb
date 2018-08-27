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
                requires :employee_level_id, type: Integer, allow_blank: false
              end
              patch do
                @effort.update_attributes!(declared(params).to_h)
                present @effort, with: Entities::Effort
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
end
