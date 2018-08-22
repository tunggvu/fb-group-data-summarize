# frozen_string_literal: true

class V1::PhaseAPI < Grape::API
  resource :projects do
    before { authenticate! }

    route_param :project_id do
      before { @project = Project.find params[:project_id] }

      resource :phases do
        desc "return all phases in project"
        get do
          authorize @project, :view?
          present @project.phases.includes_detail, with: Entities::Phase
        end

        desc "create phase in project"
        params do
          requires :name, type: String, allow_blank: false
        end
        post do
          authorize @project, :project_manager?
          present @project.phases.create!(declared(params).to_h), with: Entities::Phase
        end

        route_param :id do
          desc "return a phase"
          get do
            authorize @project, :view?
            phase = @project.phases.includes_detail.find params[:id]
            present phase, with: Entities::Phase
          end

          before { authorize @project, :project_manager? }

          desc "update a phase"
          params do
            requires :name, type: String, allow_blank: false
          end
          patch do
            phase = @project.phases.includes_detail.find params[:id]
            phase.update_attributes!(declared(params).to_h)
            present phase, with: Entities::Phase
          end

          desc "delete a phase"
          delete do
            phase = @project.phases.includes(sprints: :efforts).find params[:id]
            phase.destroy!
            { message: I18n.t("delete_success") }
          end
        end
      end
    end
  end
end
