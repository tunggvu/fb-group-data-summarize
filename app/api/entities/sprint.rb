# frozen_string_literal: true

module Entities
  class Sprint < Entities::BaseSprint
    expose :starts_on, :ends_on
  end
end
