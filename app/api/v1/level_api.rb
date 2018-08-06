# frozen_string_literal: true

class V1::LevelAPI < Grape::API
  resource :skills do
    before do
      authenticate!
      authorize :organization, :admin?
    end

    route_param :skill_id do
      before { @skill = Skill.find params[:skill_id] }

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
          before { @level = @skill.levels.find params[:id] }

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
            { message: "Delete successfully" }
          end
        end
      end
    end
  end
end
