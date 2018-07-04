# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmployeeToken, type: :model do
  it { is_expected.to belong_to :employee }
  it { is_expected.to validate_presence_of :employee }
  it { is_expected.to validate_presence_of :token }
  it { is_expected.to validate_presence_of :expired_at }
end
