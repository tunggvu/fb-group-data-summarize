# frozen_string_literal: true

class V1::RequirementAPI < Grape::API
  resource :phases do
    before { authenticate! }
    route_param :phase_id do
      before { @phase = Phase.find params[:phase_id] }

      resource :requirements do
        desc "Get all requirements"
        paginate per_page: Settings.paginate.per_page.requirement

        get do
          authorize @phase.project, :view?
          present paginate(@phase.requirements.includes(level: :skill)), with: Entities::Requirement
        end

        desc "Create requirements"
        params do
          requires :level_id, type: Integer, allow_blank: false
          requires :quantity, type: Integer, allow_blank: false
        end
        post do
          authorize @phase.project, :project_manager?
          requirement = @phase.requirements.create!(declared(params).to_h)
          present requirement, with: Entities::Requirement
        end

        route_param :id do
          before { @requirement = @phase.requirements.find params[:id] }

          desc "return a requirement"
          get do
            authorize @phase.project, :view?
            present @requirement, with: Entities::Requirement
          end

          desc "edit a requirement"
          params do
            requires :level_id, type: Integer
            requires :quantity, type: Integer
          end
          patch do
            authorize @phase.project, :project_manager?
            @requirement.update_attributes! params
            present @requirement, with: Entities::Requirement
          end

          desc "delete a requirement"
          delete do
            authorize @phase.project, :project_manager?
            @requirement.destroy!
            { message: I18n.t("delete_success") }
          end
        end
      end
    end
  end
end
