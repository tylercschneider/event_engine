module EventEngine
  module SchemaSnapshot
    class << self
      def write!(path)
        raise "EventRegistry must be loaded" unless EventEngine::EventRegistry.loaded?

        schemas = EventEngine::EventRegistry.send(:schemas)

        File.open(path, "w") do |f|
          f.puts "EventEngine::SchemaSnapshot.load! do |registry|"

          schemas.each_value do |schema|
            f.puts "  registry.register_schema("
            f.puts "    event_name: #{schema.event_name.inspect},"
            f.puts "    event_type: #{schema.event_type.inspect},"
            f.puts "    inputs: #{schema.required_inputs.inspect},"
            f.puts "    optional_inputs: #{schema.optional_inputs.inspect},"
            f.puts "    required_payload: #{schema.payload_fields.inspect},"
            f.puts "  )"
          end

          f.puts "end"
        end
      end

      # Stub loader for now — implemented next
      def load!
        yield Loader.new
      end

      class Loader
        def register_schema(**attrs)
          EventEngine::EventRegistry.register(
            EventEngine::EventDefinition.from_schema(attrs)
          )
        end
      end
    end
  end
end
