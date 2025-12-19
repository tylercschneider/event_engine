require "test_helper"

class EventRegistrySchemaViewsTest < ActiveSupport::TestCase
  setup do
    EventEngine::EventRegistry.reset!
  end

  test "schemas_by_event exposes versioned structure read-only" do
    a = EventEngine::EventDefinition::Schema.new(
      event_name: :cow_fed,
      event_type: :domain,
      required_inputs: [],
      optional_inputs: [],
      payload_fields: []
    )

    EventEngine::EventRegistry.load! do |registry|
      registry.register(a)
    end

    view = EventEngine::EventRegistry.schemas_by_event

    assert view.key?(:cow_fed)
    assert view[:cow_fed].key?(1)
    assert_equal a, view[:cow_fed][1]

    assert view.frozen?
    assert view[:cow_fed].frozen?
  end

  test "all_schemas returns flattened deterministic list" do
    a = EventEngine::EventDefinition::Schema.new(
      event_name: :b_event,
      event_type: :domain,
      required_inputs: [],
      optional_inputs: [],
      payload_fields: []
    )

    b = EventEngine::EventDefinition::Schema.new(
      event_name: :a_event,
      event_type: :domain,
      required_inputs: [],
      optional_inputs: [],
      payload_fields: []
    )

    EventEngine::EventRegistry.load! do |registry|
      registry.register(a)
      registry.register(b)
    end

    names = EventEngine::EventRegistry.all_schemas.map(&:event_name)

    assert_equal [:a_event, :b_event], names
  end
end
