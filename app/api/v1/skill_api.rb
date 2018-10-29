# frozen_string_literal: true

class V1::SkillAPI < Grape::API
  resource :skills do
    before { authenticate! }

    desc "Show all skill available"
    paginate per_page: Settings.paginate.per_page.skill

    get do
      authorize :organization, :executive?
      present paginate(Skill.includes(:levels)), with: Entities::Skill
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
      authorize :skill, :admin?
      save_params = declared params
      save_params[:levels_attributes] = save_params[:levels]
      level_names = save_params[:levels].map { |level| level[:name] }
      unless level_names.length == level_names.uniq.length
        raise_errors I18n.t("name_taken", scope: "api_error"),
          Settings.error_formatter.http_code.data_operation
      end
      save_params.delete :levels
      present Skill.create!(save_params), with: Entities::Skill
    end

    route_param :id do
      before { authorize :skill, :admin? }
      desc "Update skill"
      params do
        requires :name, type: String
        optional :logo, type: String
        requires :levels, type: Array do
          optional :id, type: Integer
          requires :name, type: String
          requires :rank, type: Integer
          optional :logo, type: String
          optional :_destroy, type: Integer
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
        skill = Skill.includes(:levels).find params[:id]
        skill.destroy!
        { message: I18n.t("delete_success") }
      end
    end
  end
end
