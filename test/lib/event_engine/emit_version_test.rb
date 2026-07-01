require "test_helper"
require "ostruct"

module EventEngine
  class EmitVersionTest < ActiveSupport::TestCase
    class CowFed < EventDefinition
      event_name :cow_fed
      event_type :domain
      input :cow
      required_payload :weight, from: :cow, attr: :weight
    end

    setup do
      compiled = DslCompiler.compile([CowFed])
      compiled.finalize!
      base = compiled.latest_for(:cow_fed)

      event_schema = EventSchema.new
      [1, 2].each do |version|
        schema = base.dup
        schema.event_version = version
        event_schema.register(schema)
      end
      event_schema.finalize!

      registry = SchemaRegistry.new
      registry.reset!
      registry.load_from_schema!(event_schema)

      @previous_registry = EventEngine.active_registry
      EventEngine.active_registry = registry
    end

    teardown do
      EventEngine.active_registry = @previous_registry
      EventEngine.reset_handlers!
    end

    test "emit targets the latest version by default" do
      event = EventEngine.emit(:cow_fed, inputs: { cow: OpenStruct.new(weight: 1) })

      assert_equal 2, event.event_version
    end

    test "emit selects a non-latest version via event_version" do
      event = EventEngine.emit(:cow_fed, inputs: { cow: OpenStruct.new(weight: 1) }, event_version: 1)

      assert_equal 1, event.event_version
    end
  end
end
