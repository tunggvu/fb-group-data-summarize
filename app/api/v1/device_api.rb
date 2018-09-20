# frozen_string_literal: true

class V1::DeviceAPI < Grape::API
  resource :devices do
    before { authenticate! }

    desc "Get all devices from all projects"
    paginate per_page: Settings.paginate.per_page.device

    get do
      present paginate(Device.all.includes(:pic, project: :product_owner)), with: Entities::Device
    end

    route_param :id do
      before { @device = Device.find params[:id] }
      desc "return device"
      get do
        present @device, with: Entities::Device
      end

      desc "Update device"
      params do
        optional :name, type: String
        optional :os_version, type: String
      end

      patch do
        authorize @device, :device_owner?

        @device.update_attributes! declared(params, include_missing: false)
        present @device, with: Entities::Device
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
end
