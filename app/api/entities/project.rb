# frozen_string_literal: true

module Entities
  class Project < Entities::BaseProject
    expose :product_owner, with: Entities::Employee
  end
end
