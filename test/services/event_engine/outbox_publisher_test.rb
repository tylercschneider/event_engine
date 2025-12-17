require "test_helper"
require "minitest/mock"

module EventEngine
  class OutboxPublisherTest < ActiveSupport::TestCase
    test "publisher does nothing when there are no unpublished events" do
      transport = Minitest::Mock.new

      EventEngine::OutboxPublisher.new(transport: transport).call

      transport.verify
    end

    test "publishes unpublished events and marks them published" do
      event = EventEngine::OutboxEvent.create!(
        event_type: "order.created",
        event_name: "order.created",
        payload: {filler: "x"}
      )

      transport = Minitest::Mock.new
      transport.expect :publish, true, [event]

      EventEngine::OutboxPublisher.new(transport: transport).call

      assert_not_nil event.reload.published_at
      transport.verify
    end

    test "does not mark event published when transport raises" do
      event = EventEngine::OutboxEvent.create!(
        event_type: "OrderCreated",
        event_name: "order.created",
        payload: { filler: "x" }
      )

      transport = Minitest::Mock.new
      transport.expect :publish, nil do |_event|
        raise StandardError, "delivery failed"
      end

      assert_raises(StandardError) do
        EventEngine::OutboxPublisher.new(transport: transport).call
      end

      assert_nil event.reload.published_at
      transport.verify
    end
  end
end
