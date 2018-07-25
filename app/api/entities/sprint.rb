# frozen_string_literal: true

module Entities
  class Sprint < Grape::Entity
    expose :id, :name

    with_options(format_with: :utc) do
      expose :start_time, as: :starts_on
      expose :end_time, as: :ends_on
    end
  end
end
