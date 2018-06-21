# frozen_string_literal: true

require "rails_helper"

RSpec.describe Role, type: :model do
  describe "#associations" do
    it { should have_many(:employee_roles) }
    it { should have_many(:employees) }
  end
end
