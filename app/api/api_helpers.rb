# frozen_string_literal: true

module ApiHelpers
  extend Grape::API::Helpers

  Grape::Entity.format_with :utc do |date|
    date.utc if date
  end
end
