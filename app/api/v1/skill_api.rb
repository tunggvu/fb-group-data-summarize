# frozen_string_literal: true

class V1::SkillAPI < Grape::API
  resource :skills do
    before { authenticate_admin! }

    desc "Show all skill available"
    get do
      present Skill.all, with: Entities::Skill
    end

    desc "Create new skill"
    params do
      requires :name, type: String, allow_blank: false
      requires :level, type: String, allow_blank: false
    end
    post do
      present Skill.create!(declared(params).to_h), with: Entities::Skill
    end

    route_param :id do
      before do
        @skill = Skill.find params[:id]
      end

      desc "Update skill"
      params do
        requires :name, type: String
        requires :level, type: String
      end
      put do
        @skill.update_attributes! declared(params).to_h
        present @skill, with: Entities::Skill
      end

      desc "Delete skill"
      delete do
        present @skill.destroy, with: Entities::Skill
      end
    end
  end
end
