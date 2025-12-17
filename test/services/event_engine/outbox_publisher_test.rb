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

    test "increments attempts when delivery fails" do
      event = EventEngine::OutboxEvent.create!(
        event_type: "OrderCreated",
        event_name: "order.created",
        payload: { filler: "x" }
      )

      transport = Minitest::Mock.new
      transport.expect :publish, nil do |_event|
        raise StandardError, "boom"
      end

      assert_raises(StandardError) do
        EventEngine::OutboxPublisher.new(transport: transport).call
      end

      assert_equal 1, event.reload.attempts
    end

    test "publishes only up to the batch size" do
      e1 = EventEngine::OutboxEvent.create!(event_type: "A", event_name: "a", payload: { x: 1 })
      e2 = EventEngine::OutboxEvent.create!(event_type: "A", event_name: "a", payload: { x: 2 })
      e3 = EventEngine::OutboxEvent.create!(event_type: "A", event_name: "a", payload: { x: 3 })

      transport = EventEngine::Transports::InMemoryTransport.new
      publisher = EventEngine::OutboxPublisher.new(transport: transport, batch_size: 2)

      publisher.call

      assert_equal [e1, e2], transport.events
      assert_nil e3.reload.published_at
    end

    test "skips events that exceeded max attempts" do
      skipped = EventEngine::OutboxEvent.create!(
        event_type: "A",
        event_name: "a",
        payload: { x: 1 },
        attempts: 5
      )

      published = EventEngine::OutboxEvent.create!(
        event_type: "A",
        event_name: "a",
        payload: { x: 2 },
        attempts: 0
      )

      transport = EventEngine::Transports::InMemoryTransport.new

      EventEngine::OutboxPublisher.new(
        transport: transport,
        batch_size: 10,
        max_attempts: 5
      ).call

      assert_equal [published], transport.events
      assert_nil skipped.reload.published_at
    end
  end
end
