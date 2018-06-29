# frozen_string_literal: true

module BaseAPI
  extend ActiveSupport::Concern

  included do
    prefix "api"
    format :json
    default_format :json

    rescue_from Grape::Exceptions::ValidationErrors, ActiveRecord::RecordNotUnique do |e|
      message = { error_code: Settings.error_formatter.error_codes.validation_errors }.merge({ errors: e.as_json })
      error! message, Settings.error_formatter.http_code.validation_errors
    end

    rescue_from APIError::Base do |e|
      error_key = e.class.name.split("::").drop(1).map(&:underscore).first
      error_code = Settings.error_formatter.error_codes.public_send error_key
      http_code = Settings.error_formatter.http_code.public_send error_key
      message = { error_code: error_code }.merge({ errors: e.as_json })
      error! message, http_code
    end

    rescue_from ActiveRecord::UnknownAttributeError, ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid,
      JSON::ParserError do |e|
      message = { error_code: Settings.error_formatter.error_codes.data_operation }.merge({ errors: e.as_json })
      error! message, Settings.error_formatter.http_code.data_operation
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      message = { error_code: Settings.error_formatter.error_codes.record_not_found }.merge({ errors: e.as_json })
      error! message, Settings.error_formatter.http_code.code_404
    end
  end
end
