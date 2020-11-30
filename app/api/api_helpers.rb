# frozen_string_literal: true

module APIHelpers
  extend Grape::API::Helpers

  Grape::Entity.format_with :utc do |date|
    date.utc if date
  end

  Grape::Entity.format_with :date do |date|
    date.strftime("%Y-%m-%d") if date
  end

  Grape::Entity.format_with :full_url do |image|
    ActionController::Base.helpers.image_url image.url
  end
end
