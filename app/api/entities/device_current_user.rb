# frozen_string_literal: true

module Entities
  class DeviceCurrentUser < Entities::BaseDevice
    expose :pic, with: Entities::Employee
    expose :project, with: Entities::DeviceProject
    expose :is_keeping do |device, options|
      options[:devices_keeping].include? device.id
    end
    expose :is_requesting do |device, options|
      options[:devices_requesting].include? device.id
    end
  end
end
