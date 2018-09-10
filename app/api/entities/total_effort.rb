# frozen_string_literal: true

module Entities
  class TotalEffort < Grape::Entity
    with_options(format_with: :date) do
      expose :start_time, :end_time
    end
    expose :value
  end
end
