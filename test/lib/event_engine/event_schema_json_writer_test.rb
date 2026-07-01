require "test_helper"
require "tempfile"
require "json"

class EventSchemaJsonWriterTest < ActiveSupport::TestCase
  def build_schema(event_name:, version:)
    EventEngine::EventDefinition::Schema.new(
      event_name: event_name,
      event_version: version,
      event_type: :domain,
      required_inputs: [:cow],
      optional_inputs: [],
      payload_fields: [{ name: :weight, required: true, from: :cow, attr: :weight }]
    )
  end

  test "writes one JSON object per event and version, sorted deterministically" do
    es = EventEngine::EventSchema.new
    es.register(build_schema(event_name: :pig_fed, version: 1))
    es.register(build_schema(event_name: :cow_fed, version: 2))
    es.register(build_schema(event_name: :cow_fed, version: 1))
    es.finalize!

    file = Tempfile.new(["event_schema", ".json"])

    EventEngine::EventSchemaJsonWriter.write(file.path, es)

    parsed = JSON.parse(File.read(file.path))

    assert_equal(
      [["cow_fed", 1], ["cow_fed", 2], ["pig_fed", 1]],
      parsed.map { |o| [o["event_name"], o["event_version"]] }
    )
  ensure
    file.unlink
  end
end
