# frozen_string_literal: true

class V1::RequestAPI < Grape::API
  resource :requests do
    route_param :id do
      before { @assignment_request = Request.find params[:id] }

      desc "Requested PIC accept device assignment request"
      params do
        optional :confirmation_token, type: String
      end
      get :confirm do
        confirmation_token = params[:confirmation_token]
        @assignment_request.confirm!(:confirmed, confirmation_token)
        present @assignment_request, with: Entities::Request
      end

      desc "Requested PIC reject device assignment request"
      params do
        optional :confirmation_token, type: String
      end

      get :reject do
        confirmation_token = params[:confirmation_token]
        @assignment_request.reject!(:rejected, confirmation_token)
        present @assignment_request, with: Entities::Request
      end
    end
  end
end
