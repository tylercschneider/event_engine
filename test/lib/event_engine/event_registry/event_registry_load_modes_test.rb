require "test_helper"

class EventRegistryLoadModesTest < ActiveSupport::TestCase
  setup do
    EventEngine::EventRegistry.reset!
  end

  test "load! via definitions compiles and registers schemas" do
    klass = Class.new(EventEngine::EventDefinition) do
      event_name "cow.fed"
      event_type "domain"
      input :cow
      required_payload :cow_id, from: :cow, attr: :id
    end

    EventEngine::EventRegistry.load!(definitions: [klass])

    schema = EventEngine::EventRegistry.current_schema("cow.fed")
    assert_equal "cow.fed", schema.event_name
  end

  test "load! via block registers schemas directly" do
    schema = EventEngine::EventDefinition::Schema.new(
      event_name: "pig.fed",
      event_type: "domain",
      required_inputs: [:pig],
      optional_inputs: [],
      payload_fields: [{ name: :pig_id, from: :pig, attr: :id }]
    )

    EventEngine::EventRegistry.load! do |registry|
      registry.register(schema)
    end

    loaded = EventEngine::EventRegistry.current_schema("pig.fed")
    assert_equal "pig.fed", loaded.event_name
  end

  test "cannot load twice" do
    EventEngine::EventRegistry.load!(definitions: [])
    assert_raises(EventEngine::EventRegistry::RegistryFrozenError) do
      EventEngine::EventRegistry.load!(definitions: [])
    end
  end
end
