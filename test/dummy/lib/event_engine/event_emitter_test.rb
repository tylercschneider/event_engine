require "test_helper"

module EventEngine
  class EventEmitterTest < ActiveSupport::TestCase
    test "creates an OutboxEvent from an EventDefinition and payload" do
      definition = EventDefinition.new(
        event_name: "order.shipped",
        event_type: "domain"
      )

      payload = { order_id: 123 }

      outbox_event =
        EventEmitter.emit(
          definition: definition,
          payload: payload
        )

      assert outbox_event.persisted?
      assert_equal "order.shipped", outbox_event.event_name
      assert_equal "domain", outbox_event.event_type
      assert_equal payload.stringify_keys, outbox_event.payload
    end
  end
end
