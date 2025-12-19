require "test_helper"

module EventEngine
  class EventRegistryTest < ActiveSupport::TestCase
    class CowFed < EventDefinition
      event_name :cow_fed
      event_type :domain
    end

    setup do
      EventRegistry.reset!
    end

    test "loads event definitions and returns schema by event_name" do
      EventRegistry.register(CowFed.schema)

      schema = EventRegistry.current_schema(:cow_fed)

      assert_equal :cow_fed, schema.event_name
      assert_equal :domain, schema.event_type
    end

    test "raises when event_name is not registered" do
      error = assert_raises(EventRegistry::UnknownEventError) { EventRegistry.current(:missing_event) }
      assert_match "missing_event", error.message
    end
  end
end
