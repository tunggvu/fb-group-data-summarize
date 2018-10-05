# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.5.1"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 5.2.0"
# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
# Use Puma as the app server
gem "puma", "~> 3.11"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
gem "bcrypt"
gem "jwt"
# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false
gem "chatwork"
gem "figaro"
gem "rack-cors", require: "rack/cors"
gem "whenever"
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'
gem "aasm"
gem "ransack"
gem "sendgrid-ruby"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "database_cleaner"
  gem "factory_bot_rails"
  gem "rspec-rails"
  gem "rswag-specs", "~> 2.0.4"
  gem "shoulda-matchers"

  gem "pry"
  gem "pry-byebug"
  gem "pry-doc"
  gem "pry-rails"
  gem "pry-stack_explorer"
end

group :development do
  gem "listen", ">= 3.0.5", "< 3.2"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "activerecord-import", require: false
gem "ancestry", "~> 3.0.2"
gem "api-pagination", "~> 4.8.1"
gem "bullet"
gem "carrierwave"
gem "carrierwave-base64"
gem "config"
gem "faker"
gem "grape"
gem "grape-entity"
gem "http-accept"
gem "i18n"
gem "kaminari", "~> 1.1.1"
gem "pundit"
gem "rswag-api", "~> 2.0.4"
gem "rswag-ui", "~> 2.0.4"
gem "rubocop-github"
gem "seed-fu"
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
