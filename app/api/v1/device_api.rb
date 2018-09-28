# frozen_string_literal: true

class V1::DeviceAPI < Grape::API
  resource :devices do
    before { authenticate! }

    desc "Get all devices from all projects by filter"
    paginate per_page: Settings.paginate.per_page.device
    params do
      optional :query, type: String
      optional :device_types, type: Array[Integer]
      optional :project_id, type: Integer
      optional :organization_id, type: Integer
    end
    get do
      search_params = {
        name_or_os_version_or_serial_code_cont: params[:query],
        device_type_in: params[:device_types],
        project_id_in: params[:project_id],
        pic_organization_id_in: params[:organization_id],
      }
      devices = Device.includes(:pic, :project).ransack(search_params).result(distinct: true)
      present paginate(devices), with: Entities::Device
    end

    route_param :id do
      desc "return device"
      get do
        device = Device.includes(requests: [:request_pic, :requester, :project]).find(params[:id])
        present device, with: Entities::DeviceDetail
      end

      desc "Update device"
      params do
        optional :name, type: String
        optional :os_version, type: String
      end

      before do
        device = Device.find(params[:id])
        authorize device, :device_owner?
      end

      patch do
        device = Device.includes(requests: [:request_pic, :requester, :project]).find(params[:id])
        device.update_attributes! declared(params, include_missing: false)
        present device, with: Entities::DeviceDetail
      end
    end

    desc "Create device"
    params do
      requires :name, type: String, allow_blank: false
      requires :serial_code, type: String, allow_blank: false
      requires :project_id, type: Integer
      requires :device_type, type: Integer
      optional :pic_id, type: Integer
      optional :os_version, type: String
    end
    post do
      authorize Project.find(params[:project_id]), :product_owner?
      present Device.create!(declared(params).to_h), with: Entities::Device
    end
  end

  resources :projects do
    before { authenticate! }

    route_param :project_id do
      resources :devices do
        route_param :id do
          resource :requests do
            desc "Create request when change owner of device"
            params do
              requires :request_project, type: Integer
              requires :request_pic, type: Integer
            end
            post do
              @device = Device.find(params[:id])
              authorize @device, :device_owner?

              present Request.create!(status: :pending, modified_date: Date.current,
                project_id: params[:request_project], request_pic_id: params[:request_pic],
                requester: current_user, device: @device), with: Entities::Request
            end
          end
        end
      end
    end

  end
end
