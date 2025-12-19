module EventEngine
  module SchemaSnapshot
    class << self
      def write!(path)
        raise "EventRegistry must be loaded" unless EventEngine::EventRegistry.loaded?

        schemas = EventEngine::EventRegistry.send(:schemas)
                                            .values
                                            .sort_by { |s| s.event_name.to_s }

        File.open(path, "w") do |f|
          f.puts "EventEngine::EventRegistry.load! do |registry|"

          schemas.each do |schema|
            f.puts "  registry.register("
            f.puts "    #{schema.to_ruby}"
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
