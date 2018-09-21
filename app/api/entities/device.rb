# frozen_string_literal: true

module Entities
  class Device < Entities::BaseDevice
    expose :project, with: Entities::DeviceProject
  end
end
