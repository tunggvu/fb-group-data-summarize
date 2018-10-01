# frozen_string_literal: true

class V1::RequestAPI < Grape::API
  resource :requests do
    route_param :id do
      before { @assignment_request = Request.find params[:id] }

      desc "Requested PIC accept device assignment request"
      params do
        optional :confirmation_token, type: String
      end
      get :accepted do
        confirmation_token = params[:confirmation_token]
        if confirmation_token && @assignment_request.authenticate?(confirmation_token)
          @assignment_request.update!(status: :approved, confirmation_digest: nil)
          @assignment_request.device.update!(pic: @assignment_request.request_pic)
          present @assignment_request, with: Entities::Request
        else
          raise APIError::InvalidEmailToken
        end
      end

      desc "Requested PIC reject device assignment request"
      params do
        optional :confirmation_token, type: String
      end

      get :rejected do
        confirmation_token = params[:confirmation_token]
        if confirmation_token && @assignment_request.authenticate?(confirmation_token)
          @assignment_request.update!(status: :rejected, confirmation_digest: nil)
          present @assignment_request, with: Entities::Request
        else
          raise APIError::InvalidEmailToken
        end
      end
    end
  end
end
