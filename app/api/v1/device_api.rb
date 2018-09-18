# frozen_string_literal: true

class V1::DeviceAPI < Grape::API
  resource :devices do
    before { authenticate! }

    desc "Get all devices from all projects"
    paginate per_page: Settings.paginate.per_page.device

    get do
      present paginate(Device.all.includes(:pic, project: :product_owner)), with: Entities::Device
    end
  end
end
