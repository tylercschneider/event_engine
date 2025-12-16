require "test_helper"

module EventEngine
  class OutboxEventTest < ActiveSupport::TestCase
    test "persists an outbox event" do
      event = OutboxEvent.create!(
        event_name: "example.event",
        event_type: "example.event",
        payload: {filler: "dummy"}
      )

      assert event.persisted?
    end

    test "outbox event is invalid without event_name" do
      event = OutboxEvent.new(event_type: "example.event")

      assert_not event.valid?
    end

    test "outbox event is invalid without event_type" do
      event = OutboxEvent.new(event_name: "example.event")

      assert_not event.valid?
    end

    test "outbox event is invalid without payload" do
      event = OutboxEvent.new(event_name: "example.event", event_type: "example.event")

      assert_not event.valid?
    end

    test "outbox event is unpublished by default" do
      event = OutboxEvent.create!(
        event_type: "example.event",
        event_name: "example.event",
        payload: {filler: "dummy"}
      )

      assert_nil event.published_at
    end
  end
end
