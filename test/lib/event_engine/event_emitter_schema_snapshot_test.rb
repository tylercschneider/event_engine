require "test_helper"
require "ostruct"
require "tempfile"

module EventEngine
  class EventEmitterSchemaSnapshotTest < ActiveSupport::TestCase
    class CowFed < EventDefinition
      event_name :cow_fed
      event_type :domain

      input :cow
      required_payload :weight, from: :cow, attr: :weight
    end

    setup do
      EventRegistry.reset!
    end

    test "emits event after loading registry from event_schema.rb" do
      # Step 1: compile schema via EventDefinition
      EventRegistry.load!(definitions: [CowFed])

      # Step 2: write schema snapshot
      file = Tempfile.new("event_schema.rb")
      SchemaSnapshot.write!(file.path)

      # Step 3: simulate fresh boot (no EventDefinitions)
      EventRegistry.reset!
      load file.path

      # Step 4: emit event using loaded schema
      cow = OpenStruct.new(weight: 500)

      event = EventEmitter.emit(
        event_name: :cow_fed,
        data: { cow: cow }
      )

      assert event.persisted?
      assert_equal "cow_fed", event.event_name
      assert_equal "domain", event.event_type
      assert_equal({ "weight" => 500 }, event.payload)
    ensure
      file.close
      file.unlink
    end
  end
end
