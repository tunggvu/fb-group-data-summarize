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
            end
            post do
              authorize @project, :project_manager?
              present @project.sprints.create!(declared(params).merge(phase_id: @phase.id)),
                with: Entities::Sprint
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
end
