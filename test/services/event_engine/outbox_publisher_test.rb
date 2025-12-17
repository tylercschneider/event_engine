require "test_helper"
require "minitest/mock"

module EventEngine
  class OutboxPublisherTest < ActiveSupport::TestCase
    test "publisher does nothing when there are no unpublished events" do
      transport = Minitest::Mock.new

      EventEngine::OutboxPublisher.new(transport: transport).call

      transport.verify
    end
  end
end
