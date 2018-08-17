# frozen_string_literal: true

module BaseAPI
  extend ActiveSupport::Concern

  included do
    prefix "api"
    format :json
    default_format :json

    rescue_from Grape::Exceptions::ValidationErrors, ActiveRecord::RecordNotUnique do |e|
      message = { error: { code: Settings.error_formatter.http_code.validation_errors,
        message: e.full_messages[0].to_s } }
      error! message, Settings.error_formatter.http_code.validation_errors
    end

    rescue_from APIError::Base, JWT::VerificationError, JWT::DecodeError, Pundit::NotAuthorizedError do |e|
      error_key = e.class.name.split("::").drop(1).map(&:underscore).first
      http_code = Settings.error_formatter.http_code.public_send error_key
      error_content = I18n.t("api_error.unauthorized") unless e.is_a? APIError::Base
      message = { error: { code: http_code, message: (error_content ? error_content : error_key.gsub("_", " ")) } }
      error! message, http_code
    end

    rescue_from ActiveRecord::UnknownAttributeError, ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid,
      JSON::ParserError, ActiveRecord::RecordNotDestroyed do |e|
      message = { error: { code: Settings.error_formatter.http_code.data_operation, message: e.as_json } }
      error! message, Settings.error_formatter.http_code.data_operation
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      message = { error: { code: Settings.error_formatter.http_code.record_not_found, message: I18n.t("api_error.invalid_id", model: e.model, id: e.id) } }
      error! message, Settings.error_formatter.http_code.record_not_found
    end

    helpers Pundit
    helpers do
      def authenticate!
        raise APIError::Unauthorized unless EmployeeToken.verify(access_token_header)
        raise APIError::Unauthenticated unless current_user
      end

      def current_user
        @current_user ||= EmployeeToken.find_by_token(access_token_header)&.employee
      end

      def access_token_header
        auth_header = headers[Settings.access_token_header]
        return nil unless auth_header
        auth_header.scan(/^#{Settings.access_token_value_prefix} (.+)$/i)[0] ?
          auth_header.scan(/^#{Settings.access_token_value_prefix} (.+)$/i)[0].first : nil
      end

      def set_locale
        language = headers["Accept-Language"].present? ? headers["Accept-Language"] : I18n.default_locale.to_s
        I18n.locale = HTTP::Accept::Languages.parse(language)[0].locale
      end
    end
  end
end
