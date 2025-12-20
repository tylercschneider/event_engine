module EventEngine
  class EventRegistry
    class UnknownEventError < StandardError; end
    class RegistryFrozenError < StandardError; end

    class << self
      def events
        raise RegistryFrozenError, "EventRegistry not loaded" unless loaded?
        @loaded_event_schema.events
      end

      def reset!
        @schemas = {}
        @loaded = false
      end

      def load_from_schema!(event_schema)
        raise RegistryFrozenError, "EventRegistry already loaded" if loaded?
        @loaded_event_schema = event_schema

        @loaded = true
        self
      end

      def schema(event_name, version: nil)
        raise RegistryFrozenError, "EventRegistry not loaded" unless loaded?

        schema =
          if version
            @loaded_event_schema.schema_for(event_name, version)
          else
            @loaded_event_schema.latest_for(event_name)
          end

        unless schema
          raise UnknownEventError,
                "Unknown #{version ? "version #{version} for " : ""}event: #{event_name}"
        end

        schema
      end

      def loaded?
        @loaded == true
      end
    end
  end
end
