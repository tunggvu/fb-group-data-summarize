# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Emres
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    config.time_zone = "Hanoi"
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**/*.{rb,yml}").to_s]
    config.autoload_paths << Rails.root.join("lib")
    config.eager_load_paths << Rails.root.join("lib")

    if ENV["FRONTEND_HOST"].present?
      config.middleware.insert_before 0, Rack::Cors do
        allow do
          origins ENV["FRONTEND_HOST"]
          resource "/api/v1/*",
            headers: :any,
            methods: [:get, :post, :options, :delete, :put, :patch],
            expose: ["X-Page", "X-Per-Page", "X-Total"]
        end
        allow do
          origins ENV["FRONTEND_HOST"]
          resource "/uploads/*", headers: :any, methods: :get
        end
      end
    end

    ApiPagination.configure do |config|
      config.paginator = :kaminari
      config.total_header = "X-Total"
      config.per_page_header = "X-Per-Page"
      config.page_header = "X-Page"
      config.page_param = :page
      config.per_page_param = :limit
    end
  end
end
