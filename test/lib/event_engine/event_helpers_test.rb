require "test_helper"
require "ostruct"

module EventEngine
  class EventHelpersTest < ActiveSupport::TestCase
    class CowFed < EventDefinition
      event_name :cow_fed
      event_type :domain

      input :cow
      required_payload :weight, from: :cow, attr: :weight
    end

    setup do
      # 1. Compile DSL → schema
      compiled = DslCompiler.compile([CowFed])
      compiled.finalize!

      # 2. Merge into EventSchema (no file in this test)
      event_schema = EventSchema.new
      compiled.events.each do |event|
        schema = compiled.latest_for(event).dup
        schema.event_version = 1
        event_schema.register(schema)
      end
      event_schema.finalize!

      # 3. Load runtime registry from schema
      EventRegistry.reset!
      EventRegistry.load_from_schema!(event_schema)

      # 4. Install helpers from runtime registry
      EventEngine.install_helpers(registry: EventRegistry)
    end

    test "defines helper method on EventEngine" do
      assert EventEngine.respond_to?(:cow_fed)
    end

    test "helper emits an OutboxEvent" do
      cow = OpenStruct.new(weight: 500)

      event = EventEngine.cow_fed(cow: cow)

      assert event.persisted?
      assert_equal "cow_fed", event.event_name
      assert_equal({ "weight" => 500 }, event.payload)
    end
  end
end
