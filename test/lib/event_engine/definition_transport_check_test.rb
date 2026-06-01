require "test_helper"

module EventEngine
  class DefinitionTransportCheckTest < ActiveSupport::TestCase
    def registry_with_level(level)
      schema = EventDefinition::Schema.new(
        event_name: :sale_processed,
        event_version: 1,
        event_type: :domain,
        event_level: level,
        required_inputs: [],
        optional_inputs: [],
        payload_fields: []
      )
      event_schema = EventSchema.new
      event_schema.register(schema)
      event_schema.finalize!

      registry = SchemaRegistry.new
      registry.reset!
      registry.load_from_schema!(event_schema)
      registry
    end

    def capture_log
      io = StringIO.new
      DefinitionTransportCheck.run(registry: registry_with_level(4), transport: Transports::NullTransport.new, logger: Logger.new(io))
      io.string
    end

    test "warns when a level 4 event has no real transport configured" do
      assert_match(/sale_processed/, capture_log)
    end
  end
end
