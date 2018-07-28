# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmployeeLevel, type: :model do
  describe "#associations" do
    it { should belong_to(:level) }
    it { should belong_to(:employee) }
  end
end
