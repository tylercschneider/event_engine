require "test_helper"

module EventEngine
  class EventDefinitionTest < ActiveSupport::TestCase
    test "stores event_name and event_type" do
      definition = EventDefinition.new(
        event_name: "order.shipped",
        event_type: "domain"
      )

      assert_equal "order.shipped", definition.event_name
      assert_equal "domain", definition.event_type
    end

    test "raises error when event_name is missing" do
      error = assert_raises(ArgumentError) do
        EventDefinition.new(event_name: nil, event_type: "domain")
      end

      assert_match "event_name", error.message
    end

    test "raises error when event_type is missing" do
      error = assert_raises(ArgumentError) do
        EventDefinition.new(event_name: "order.shipped", event_type: nil)
      end

      assert_match "event_type", error.message
    end

    test "raises error when payload is not a hash" do
      definition = EventDefinition.new(
        event_name: "order.shipped",
        event_type: "domain"
      )

      error = assert_raises(ArgumentError) do
        definition.payload
      end

      assert_match "payload must be a Hash", error.message
    end

    test "event definition exposes outbox attributes" do
      definition = Class.new(EventDefinition) do
        def build_payload
          { order_id: 123 }
        end
      end.new(
        event_name: "order.shipped",
        event_type: "domain"
      )

      result = definition.to_outbox_attributes

      assert_kind_of Hash, result
      assert_equal "order.shipped", result[:event_name]
      assert_equal "domain", result[:event_type]
      assert_equal({ order_id: 123 }, result[:payload])
    end
  end
end
