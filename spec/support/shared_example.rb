# frozen_string_literal: true

RSpec.shared_examples "unauthenticated" do
  response "401", "unauthenticated" do
    let("Emres-Authorization") { "" }
    run_test! do |response|
      expected = {
        error: {
          code: Settings.error_formatter.http_code.unauthenticated,
          message: I18n.t("api_error.unauthenticated")
        }
      }
      expect(response.body).to eq expected.to_json
    end
  end
end

RSpec.shared_examples "null digest" do
  it "should have null confirmation digest" do
    expect(request.reload.confirmation_digest).to be_nil
  end
end
