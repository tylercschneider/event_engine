require "test_helper"

module EventEngine
  class EventEmitterTest < ActiveSupport::TestCase
    test "creates an OutboxEvent from an EventDefinition and payload" do
      definition = Class.new(EventDefinition) do
        def build_payload
          { random: "filler" }
        end
      end.new(
        event_name: "order.shipped",
        event_type: "domain"
      )

      outbox_event = EventEmitter.emit(definition: definition)

      assert outbox_event.persisted?
      assert_equal "order.shipped", outbox_event.event_name
      assert_equal "domain", outbox_event.event_type
      assert_equal({ random: "filler" }.stringify_keys, outbox_event.payload)
    end
  end
end
