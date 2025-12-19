require "test_helper"
require "tempfile"

class SchemaSnapshotWriteTest < ActiveSupport::TestCase
  setup do
    EventEngine::EventRegistry.reset!
  end

  test "writes executable event_schema.rb that registers schemas" do
    klass = Class.new(EventEngine::EventDefinition) do
      event_name "cow.fed"
      event_type "domain"
      input :cow
      required_payload :cow_id, from: :cow, attr: :id
    end

    EventEngine::EventRegistry.load!(definitions: [klass])

    file = Tempfile.new("event_schema.rb")
    EventEngine::SchemaSnapshot.write!(file.path)

    contents = File.read(file.path)

    assert_includes contents, "EventEngine::EventRegistry.load!"
    assert_includes contents, "EventEngine::EventDefinition::Schema.new"
    assert_includes contents, 'event_name: "cow.fed"'
    assert_includes contents, "payload_fields:"
  ensure
    file.close
    file.unlink
  end
end
