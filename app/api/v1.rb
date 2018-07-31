# frozen_string_literal: true

class V1 < Grape::API
  extend Dummy
  version "v1", using: :path

  mount TestAPI
  mount SessionAPI
  mount OrganizationAPI
  mount EmployeeAPI
  mount SkillAPI
  mount ProjectAPI
  mount PhaseAPI
  mount RequirementAPI
  mount SprintAPI
  mount ProfileAPI
  mount LevelAPI

  desc "Return the current API version - V1."
  get do
    {version: "v1"}
  end
end
