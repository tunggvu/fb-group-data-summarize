# frozen_string_literal: true

module Entities
  class Device < Grape::Entity
    expose :id, :name, :serial_code, :device_type, :os_version
    expose :pic, with: Entities::Employee
    expose :project, with: Entities::Project
  end
end
