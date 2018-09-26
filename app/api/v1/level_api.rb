# frozen_string_literal: true

class V1::LevelAPI < Grape::API
  resource :skills do
    route_param :skill_id do
      before do
        authenticate!
        authorize :organization, :admin?
        @skill = Skill.find params[:skill_id]
      end

      resource :levels do
        desc "Create new level"
        params do
          requires :name, type: String, allow_blank: false
          requires :rank, type: Integer, allow_blank: false
          optional :logo, type: String
        end
        post do
          present @skill.levels.create!(declared(params).to_h), with: Entities::Level
        end

        route_param :id do
          before do
            @level = @skill.levels.find params[:id]
          end

          desc "Update a level"
          params do
            requires :name, type: String, allow_blank: false
            requires :rank, type: Integer, allow_blank: false
            optional :logo, type: String
          end
          patch do
            @level.update_attributes!(declared(params, include_mising: false).to_h)
            present @level, with: Entities::Level
          end

          desc "Delete a level"
          delete do
            @level.destroy!
            { message: I18n.t("delete_success") }
          end
        end
      end
    end
  end
end
