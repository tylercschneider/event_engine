require "test_helper"
require "ostruct"

module EventEngine
  class EventEmitterTest < ActiveSupport::TestCase
    class CowFed < EventDefinition
      event_name :cow_fed
      event_type :domain

      input :cow
      required_payload :weight, from: :cow, attr: :weight
    end

    setup do
      # 1. Compile DSL → compiled schemas
      compiled = DslCompiler.compile([CowFed])
      compiled.finalize!

      # 2. Build an EventSchema (no file involved in this test)
      event_schema = EventSchema.new
      compiled.events.each do |event_name|
        schema = compiled.latest_for(event_name).dup
        schema.event_version = 1
        event_schema.register(schema)
      end
      event_schema.finalize!

      # 3. Load runtime registry from schema
      EventRegistry.reset!
      EventRegistry.load_from_schema!(event_schema)
    end

    test "emits an OutboxEvent via registry and builder" do
      cow = OpenStruct.new(weight: 500)

      event = EventEmitter.emit(
        event_name: :cow_fed,
        data: { cow: cow }
      )

      assert event.persisted?
      assert_equal "cow_fed", event.event_name
      assert_equal "domain", event.event_type
      assert_equal({ "weight" => 500 }, event.payload)
    end
  end
end
