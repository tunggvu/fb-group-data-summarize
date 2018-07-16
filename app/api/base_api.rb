# frozen_string_literal: true

module BaseAPI
  extend ActiveSupport::Concern

  included do
    prefix "api"
    format :json
    default_format :json

    rescue_from Grape::Exceptions::ValidationErrors, ActiveRecord::RecordNotUnique do |e|
      message = { error_code: Settings.error_formatter.error_codes.validation_errors, errors: e.as_json }
      error! message, Settings.error_formatter.http_code.validation_errors
    end

    rescue_from APIError::Base, JWT::VerificationError, JWT::DecodeError do |e|
      error_key = e.class.name.split("::").drop(1).map(&:underscore).first
      error_code = Settings.error_formatter.error_codes.public_send error_key
      http_code = Settings.error_formatter.http_code.public_send error_key
      error_content = I18n.t("api_error.unauthorized") if [JWT::VerificationError, JWT::DecodeError].include?(e.class)
      message = { error_code: error_code, errors: (error_content ? error_content : error_key.gsub("_", " ")) }
      error! message, http_code
    end

    rescue_from ActiveRecord::UnknownAttributeError, ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid,
      JSON::ParserError do |e|
      message = { error_code: Settings.error_formatter.error_codes.data_operation, errors: e.as_json }
      error! message, Settings.error_formatter.http_code.data_operation
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      message = { error_code: Settings.error_formatter.error_codes.record_not_found, errors: e.as_json }
      error! message, Settings.error_formatter.http_code.record_not_found
    end

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

      def authenticate_admin!
        authenticate!
        raise APIError::Unauthorized unless current_user.is_admin?
      end

      def authenticate_organization_manager!(organization)
        authenticate!
        raise APIError::Unauthorized unless current_user.is_manager?(organization)
      end

      Organization.levels.keys.each do |role|
        define_method "authenticate_admin_or_higher_#{role}_manager_of!" do |org|
          raise APIError::Unauthorized unless current_user.is_admin? || current_user.send("is_higher_#{role}_manager_of?", org)
        end
      end
    end
  end
end
