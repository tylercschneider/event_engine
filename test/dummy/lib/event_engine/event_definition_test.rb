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
  end
end
