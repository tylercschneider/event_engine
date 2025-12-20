require "test_helper"

class EventSchemaMergeTest < ActiveSupport::TestCase
  def schema(event_name:, version:, payload:)
    EventEngine::EventDefinition::Schema.new(
      event_name: event_name,
      event_version: version,
      event_type: :domain,
      required_inputs: [:cow],
      optional_inputs: [],
      payload_fields: payload
    )
  end

  def compiled_schema(event_name:, payload:)
    EventEngine::EventDefinition::Schema.new(
      event_name: event_name,
      event_version: nil, # compiled has no version yet
      event_type: :domain,
      required_inputs: [:cow],
      optional_inputs: [],
      payload_fields: payload
    )
  end

  test "does not create new version when compiled matches latest" do
    file = EventEngine::EventSchema.new
    file.register(schema(event_name: :cow_fed, version: 1, payload: [{ name: :w, from: :cow, attr: :weight }]))
    file.finalize!

    compiled = EventEngine::CompiledSchemaRegistry.new
    compiled.register(compiled_schema(event_name: :cow_fed, payload: [{ name: :w, from: :cow, attr: :weight }]))

    merged = EventEngine::EventSchemaMerger.merge(compiled, EventEngine::FileLoadedRegistry.new(file))

    assert_equal [1], merged.versions_for(:cow_fed)
  end

  test "creates new version when compiled differs from latest" do
    file = EventEngine::EventSchema.new
    file.register(schema(event_name: :cow_fed, version: 1, payload: [{ name: :w, from: :cow, attr: :weight }]))
    file.finalize!

    compiled = EventEngine::CompiledSchemaRegistry.new
    compiled.register(compiled_schema(event_name: :cow_fed, payload: [{ name: :age, from: :cow, attr: :age }]))

    merged = EventEngine::EventSchemaMerger.merge(compiled, EventEngine::FileLoadedRegistry.new(file))

    assert_equal [1, 2], merged.versions_for(:cow_fed)
  end

  test "reverting schema creates new version not reuse" do
    file = EventEngine::EventSchema.new
    file.register(schema(event_name: :cow_fed, version: 1, payload: [{ name: :w, from: :cow, attr: :weight }]))
    file.register(schema(event_name: :cow_fed, version: 2, payload: [{ name: :age, from: :cow, attr: :age }]))
    file.finalize!

    compiled = EventEngine::CompiledSchemaRegistry.new
    compiled.register(compiled_schema(event_name: :cow_fed, payload: [{ name: :w, from: :cow, attr: :weight }]))

    merged = EventEngine::EventSchemaMerger.merge(compiled, EventEngine::FileLoadedRegistry.new(file))

    assert_equal [1, 2, 3], merged.versions_for(:cow_fed)
  end
end
