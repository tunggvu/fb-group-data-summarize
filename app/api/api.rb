# frozen_string_literal: true

class API < Grape::API
  include BaseAPI
  include ApiHelpers

  mount API::V1
end
