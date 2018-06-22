# frozen_string_literal: true

class API < Grape::API
  include BaseAPI

  mount API::V1
end
