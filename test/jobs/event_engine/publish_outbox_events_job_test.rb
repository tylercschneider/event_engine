require "test_helper"

class EventEngine::PublishOutboxEventsJobTest < ActiveJob::TestCase
  test "job invokes the outbox publisher" do
    event = EventEngine::OutboxEvent.create!(
      event_type: "OrderCreated",
      event_name: "order.created",
      payload: { filler: "x" }
    )

    transport = EventEngine::Transports::InMemoryTransport.new
    EventEngine.configure { |c| c.transport = transport }

    EventEngine::PublishOutboxEventsJob.perform_now

    assert_not_nil event.reload.published_at
    assert_equal [event], transport.events
  end

  test "job uses configured transport" do
    event = EventEngine::OutboxEvent.create!(
      event_type: "OrderCreated",
      event_name: "order.created",
      payload: { filler: "x" }
    )

    transport = EventEngine::Transports::InMemoryTransport.new
    EventEngine.configure { |c| c.transport = transport }

    EventEngine::PublishOutboxEventsJob.perform_now

    assert_equal [event], transport.events
    assert_not_nil event.reload.published_at
  end
end
