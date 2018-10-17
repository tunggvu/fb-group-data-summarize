# frozen_string_literal: true

module Entities
  class BaseDevice < Grape::Entity
    expose :id, :name, :serial_code, :device_type, :os_version
    expose :project, with: Entities::BaseProject
  end
end
