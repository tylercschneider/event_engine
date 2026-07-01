require "test_helper"
require "ostruct"

module EventEngine
  class EmitTest < ActiveSupport::TestCase
    class CowFed < EventDefinition
      event_name :cow_fed
      event_type :domain

      input :cow
      required_payload :weight, from: :cow, attr: :weight
    end

    setup do
      @previous_registry = EventEngine.schema_registry

      compiled = DslCompiler.compile([CowFed])
      compiled.finalize!

      event_schema = EventSchema.new
      compiled.events.each do |event|
        schema = compiled.latest_for(event).dup
        schema.event_version = 1
        event_schema.register(schema)
      end
      event_schema.finalize!

      registry = SchemaRegistry.new
      registry.load_from_schema!(event_schema)
      EventEngine.schema_registry = registry
    end

    teardown do
      EventEngine.schema_registry = @previous_registry
      EventEngine.reset_handlers!
    end

    test "emit builds the payload from the given inputs" do
      cow = OpenStruct.new(weight: 500)

      event = EventEngine.emit(:cow_fed, inputs: { cow: cow })

      assert_equal({ weight: 500 }, event.payload)
    end
  end
end
