# frozen_string_literal: true

class V1::PhaseAPI < Grape::API
  resource :projects do
    before { authenticate! }

    route_param :project_id do
      before { @project = Project.find params[:project_id] }

      resource :phases do
        desc "return all phases in project"
        get do
          present @project.phases, with: Entities::Phase
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
          before { @phase = @project.phases.find params[:id] }

          desc "return a phase"
          get do
            present @phase, with: Entities::Phase
          end

          desc "update a phase"
          params do
            requires :name, type: String
          end
          patch do
            authorize @project, :project_manager?
            @phase.update_attributes!(declared(params).to_h)
            present @phase, with: Entities::Phase
          end

          desc "delete a phase"
          delete do
            authorize @project, :project_manager?
            @phase.destroy!
            { message: "Delete successfully" }
          end
        end
      end
    end
  end
end
