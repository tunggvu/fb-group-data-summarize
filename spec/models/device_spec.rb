# frozen_string_literal: true

require "rails_helper"

RSpec.describe Device, type: :model do
  describe "#associations" do
    it { should have_many(:requests) }
    it { should belong_to(:project) }
    it { should belong_to(:pic) }
  end
end
