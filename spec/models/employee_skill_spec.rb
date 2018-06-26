# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmployeeSkill, type: :model do
  describe "#associations" do
    it { should belong_to(:skill) }
    it { should belong_to(:employee) }
  end
end
