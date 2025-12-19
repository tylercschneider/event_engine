require "test_helper"
require "tempfile"

class SchemaSnapshotDeterminismTest < ActiveSupport::TestCase
  setup do
    EventEngine::EventRegistry.reset!
  end

  test "snapshot orders schemas deterministically by event_name" do
    a = EventEngine::EventDefinition::Schema.new(
      event_name: "b.event",
      event_type: "domain",
      required_inputs: [],
      optional_inputs: [],
      payload_fields: []
    )

    b = EventEngine::EventDefinition::Schema.new(
      event_name: "a.event",
      event_type: "domain",
      required_inputs: [],
      optional_inputs: [],
      payload_fields: []
    )

    EventEngine::EventRegistry.load! do |registry|
      registry.register(a)
      registry.register(b)
    end

    file = Tempfile.new("event_schema.rb")
    EventEngine::SchemaSnapshot.write!(file.path)

    contents = File.read(file.path)

    assert contents.index("a.event") < contents.index("b.event")
  ensure
    file.close
    file.unlink
  end

  test "schemas are frozen after load" do
    schema = EventEngine::EventDefinition::Schema.new(
      event_name: "cow.fed",
      event_type: "domain",
      required_inputs: [],
      optional_inputs: [],
      payload_fields: []
    )

    EventEngine::EventRegistry.load! do |registry|
      registry.register(schema)
    end

    loaded = EventEngine::EventRegistry.current_schema("cow.fed")

    assert loaded.frozen?
    assert_raises(FrozenError) { loaded.event_name = "cow.fed.v2" }
  end
end
