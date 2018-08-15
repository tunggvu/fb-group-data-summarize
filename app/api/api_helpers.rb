# frozen_string_literal: true

module ApiHelpers
  extend Grape::API::Helpers

  Grape::Entity.format_with :utc do |date|
    date.utc if date
  end

  Grape::Entity.format_with :date do |date|
    date.strftime("%Y-%m-%d") if date
  end
end
