# frozen_string_literal: true

class V1 < Grape::API
  version "v1", using: :path

  mount Organizations
  mount TestAPI

  desc "Return the current API version - V1."
  get do
    {version: "v1"}
  end
end
