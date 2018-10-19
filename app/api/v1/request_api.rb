# frozen_string_literal: true

class V1::RequestAPI < Grape::API
  resource :requests do
    route_param :id do
      before { @device_request = Request.find params[:id] }

      desc "Requested PIC accept device assignment request"
      params do
        requires :confirmation_token, type: String, allow_blank: false
      end
      get :confirm do
        confirmation_token = params[:confirmation_token]
        @device_request.confirm!(:confirmed, confirmation_token)
        present @device_request, with: Entities::Request
      end

      desc "Requested PIC reject device assignment request"
      params do
        requires :confirmation_token, type: String, allow_blank: false
      end

      get :reject do
        confirmation_token = params[:confirmation_token]
        @device_request.reject!(:rejected, confirmation_token)
        present @device_request, with: Entities::Request
      end

      desc "PO approves device borrow request"
      params do
        requires :confirmation_token, type: String, allow_blank: false
      end

      get :approve do
        confirmation_token = params[:confirmation_token]
        @device_request.approve!(:approved, confirmation_token)
        present @device_request, with: Entities::Request
      end
    end
  end
end
