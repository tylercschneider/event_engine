require "test_helper"

module EventEngine
  class OutboxEventTest < ActiveSupport::TestCase
    test "persists an outbox event" do
      event = OutboxEvent.create!(
        event_name: "example.event",
      )

      assert event.persisted?
    end
  end
end
