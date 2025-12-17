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
  end
end
