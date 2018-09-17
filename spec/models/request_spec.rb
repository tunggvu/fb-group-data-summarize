# frozen_string_literal: true

require "rails_helper"

RSpec.describe Request, type: :model do
  describe "#associations" do
    it { should belong_to(:device) }
    it { should belong_to(:project) }
    it { should belong_to(:request_pic) }
    it { should belong_to(:requester) }
  end
end
