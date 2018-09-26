# frozen_string_literal: true

module Entities
  class DeviceDetail < Entities::Device
    expose :project, with: Entities::BaseProject
    expose :requests, with: Entities::Request, as: :history
  end
end