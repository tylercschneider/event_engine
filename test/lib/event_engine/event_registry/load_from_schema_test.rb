require "test_helper"

class EventRegistryLoadFromSchemaTest < ActiveSupport::TestCase
  def build_schema(event_name:, version:)
    EventEngine::EventDefinition::Schema.new(
      event_name: event_name,
      event_version: version,
      event_type: :domain,
      required_inputs: [:cow],
      optional_inputs: [],
      payload_fields: [{ name: :weight, from: :cow, attr: :weight }]
    )
  end

  test "loads latest schema per event from EventSchema" do
    es = EventEngine::EventSchema.new
    es.register(build_schema(event_name: :cow_fed, version: 1))
    es.register(build_schema(event_name: :cow_fed, version: 2))
    es.register(build_schema(event_name: :pig_fed, version: 1))
    es.finalize!

    EventEngine::EventRegistry.reset!
    EventEngine::EventRegistry.load_from_schema!(es)

    cow = EventEngine::EventRegistry.schema(:cow_fed)
    pig = EventEngine::EventRegistry.schema(:pig_fed)

    assert_equal 2, cow.event_version
    assert_equal 1, pig.event_version
  end
end
