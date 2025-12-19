require "test_helper"

class EventRegistryVersionsTest < ActiveSupport::TestCase
  setup do
    EventEngine::EventRegistry.reset!
  end

  test "registers schema under default version 1" do
    schema = EventEngine::EventDefinition::Schema.new(
      event_name: :cow_fed,
      event_type: :domain,
      required_inputs: [],
      optional_inputs: [],
      payload_fields: []
    )

    EventEngine::EventRegistry.load! do |registry|
      registry.register(schema)
    end

    current = EventEngine::EventRegistry.current_schema(:cow_fed)

    assert_equal schema, current
  end

  test "stores schemas by version internally" do
    schema = EventEngine::EventDefinition::Schema.new(
      event_name: :cow_fed,
      event_type: :domain,
      required_inputs: [],
      optional_inputs: [],
      payload_fields: []
    )

    EventEngine::EventRegistry.load! do |registry|
      registry.register(schema)
    end

    storage = EventEngine::EventRegistry.schemas_by_event

    assert storage.key?(:cow_fed)
    assert storage[:cow_fed].key?(1)
    assert_equal schema, storage[:cow_fed][1]
  end
end
