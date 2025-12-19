require "test_helper"
require "tempfile"

class SchemaSnapshotTest < ActiveSupport::TestCase
  setup do
    EventEngine::EventRegistry.reset!
    @file = Tempfile.new("event_schema.rb")
  end

  test "writes a deterministic schema snapshot from loaded registry" do
    klass = Class.new(EventEngine::EventDefinition) do
      event_name "cow.fed"
      event_type "domain"
      input :cow
      required_payload :cow_id, from: :cow, attr: :id
    end

    EventEngine::EventRegistry.load!(definitions: [klass])

    EventEngine::SchemaSnapshot.write!(@file.path)

    contents = File.read(@file.path)

    assert_includes contents, "EventEngine::SchemaSnapshot.load!"
    assert_includes contents, "cow.fed"
    assert_includes contents, "domain"
  ensure
    @file.close
    @file.unlink
  end
end
