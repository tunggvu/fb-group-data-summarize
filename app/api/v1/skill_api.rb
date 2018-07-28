# frozen_string_literal: true

class V1::SkillAPI < Grape::API
  resource :skills do
    before { authenticate_admin! }

    desc "Show all skill available"
    get do
      present Skill.includes(:levels).all, with: Entities::Skill
    end

    desc "Create new skill"
    params do
      requires :name, type: String, allow_blank: false
      optional :logo, type: String
      requires :levels, type: Array do
        requires :name, type: String, allow_blank: false
        requires :rank, type: Integer, allow_blank: false
        optional :logo, type: String
      end
    end
    post do
      save_params = declared params
      save_params[:levels_attributes] = save_params[:levels]
      save_params.delete :levels
      present Skill.create!(save_params), with: Entities::Skill
    end

    route_param :id do
      desc "Update skill"
      params do
        requires :name, type: String
        optional :logo, type: String
        requires :levels, type: Array do
          requires :id, type: Integer
          requires :name, type: String
          requires :rank, type: Integer
          optional :logo, type: String
        end
      end
      patch do
        skill = Skill.find params[:id]
        save_params = declared params
        save_params[:levels_attributes] = save_params[:levels]
        save_params.delete :levels
        skill.update_attributes! save_params
        present skill, with: Entities::Skill
      end

      desc "Delete skill"
      delete do
        skill = Skill.includes(levels: [:requirements, :employee_levels]).find params[:id]
        skill.destroy!
        { message: "Delete successfully" }
      end
    end
  end
end
