# frozen_string_literal: true

module ApiHelper
  def expect_http_status(http_status)
    expect(response).to have_http_status(http_status)
  end

  def error_code_list
    Settings.error_formatter.error_codes
  end

  def error_code
    response_body["error_code"]
  end

  def response_body
    JSON.parse(response.body)
  end

  def auth_header(access_token)
    {
      :CONTENT_TYPE => "application/json",
      :"#{Settings.access_token_header}" => "#{Settings.access_token_value_prefix} #{access_token}"
    }
  end
end
