require "test_helper"

class EventRegistryPublicSchemaAccessTest < ActiveSupport::TestCase
  setup do
    EventEngine::EventRegistry.reset!
  end

  test "exposes all schemas via all_schemas in deterministic order" do
    a = EventEngine::EventDefinition::Schema.new(
      event_name: :a_event,
      event_type: :domain,
      required_inputs: [],
      optional_inputs: [],
      payload_fields: []
    )

    b = EventEngine::EventDefinition::Schema.new(
      event_name: :b_event,
      event_type: :domain,
      required_inputs: [],
      optional_inputs: [],
      payload_fields: []
    )

    EventEngine::EventRegistry.load! do |registry|
      registry.register(b)
      registry.register(a)
    end

    schemas = EventEngine::EventRegistry.all_schemas

    assert_equal [:a_event, :b_event], schemas.map(&:event_name)
  end
end
