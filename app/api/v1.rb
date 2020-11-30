# frozen_string_literal: true

class V1 < Grape::API
  extend Dummy
  version "v1", using: :path

  mount SessionAPI

  desc "Return the current API version - V1."
  get do
    {version: "v1"}
  end
end
