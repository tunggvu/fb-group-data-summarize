# frozen_string_literal: true

module Entities
  class Organizations < Grape::Entity
    expose :id, :parent_id, :manager_id, :level, :name, :ancestry
  end
end
