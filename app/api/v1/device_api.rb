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
      current_device_requests = current_user.created_requests.is_waiting.ids
      device_own_ids = current_user.device_ids
      devices = Device.includes(:pic, :project).ransack(search_params).result(distinct: true).order :name
      present paginate(devices), with: Entities::DeviceCurrentUser, devices_keeping: device_own_ids, devices_requesting: current_device_requests
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
      patch do
        device = Device.find(params[:id])
        authorize device, :device_owner?
        device = Device.includes(requests: [:request_pic, :requester, :project]).find(params[:id])
        device.update_attributes! declared(params, include_missing: false)
        present device, with: Entities::DeviceDetail
      end

      resource :requests do
        desc "Borrow device"
        params do
          requires :request_project, type: Integer
          requires :request_pic, type: Integer
        end
        post do
          device = Device.find(params[:id])
          authorize device, :user_can_borrow?

          request = Request.create!(status: :pending, modified_at: Time.current,
            project_id: params[:request_project], request_pic_id: params[:request_pic],
            requester: current_user, device: device)
          present request, with: Entities::Request
        end
      end
    end

    desc "Create device"
    params do
      requires :name, type: String, allow_blank: false
      requires :serial_code, type: String, allow_blank: false
      requires :project_id, type: Integer, allow_blank: false
      requires :device_type, type: Integer, allow_blank: false
      optional :os_version, type: String
    end
    post do
      authorize Project.find(params[:project_id]), :project_manager?
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
              device = Device.find(params[:id])
              authorize device, :device_owner?
              request = Request.create!(status: :approved, modified_at: Time.current,
                project_id: params[:request_project], request_pic_id: params[:request_pic],
                requester: current_user, device: device)
              present request, with: Entities::Request
            end
          end
        end
      end
    end
  end
end
