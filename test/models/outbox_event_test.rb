require "test_helper"

module EventEngine
  class OutboxEventTest < ActiveSupport::TestCase
    test "persists an outbox event" do
      event = OutboxEvent.create!(
        event_name: "example.event",
      )

      assert event.persisted?
    end

    test "outbox event is invalid without event_name" do
      event = OutboxEvent.new()

      assert_not event.valid?
    end
  end
end
