# frozen_string_literal: true

class V1::LevelAPI < Grape::API
  resource :skills do
    before { authenticate_admin! }

    route_param :skill_id do
      before { @skill = Skill.find params[:skill_id] }

      resource :levels do
        desc "Create new skill"
        post do
          # TODO: Dummy
          Dummy::POST_LEVEL
        end

        route_param :id do
          desc "Update skill"
          patch do
            # TODO: Dummy
            Dummy::PATCH_LEVEL
          end

          desc "Delete skill"
          delete do
            { message: "Delete successfully" }
          end
        end
      end
    end
  end
end
