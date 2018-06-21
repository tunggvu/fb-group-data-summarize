# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmployeeRole, type: :model do
  describe "#associations" do
    it { should belong_to(:role) }
    it { should belong_to(:employee) }
  end
end
