# frozen_string_literal: true

module Entities
  class Device < Entities::BaseDevice
    expose :pic, with: Entities::Employee
    expose :project, with: Entities::DeviceProject
  end
end
