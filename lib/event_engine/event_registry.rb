module EventEngine
  class EventRegistry
    class UnknownEventError < StandardError; end
    class RegistryFrozenError < StandardError; end

    class << self
      def reset!
        @schemas = {}
        @loaded = false
      end

      def load_from_schema!(event_schema)
        raise RegistryFrozenError, "EventRegistry already loaded" if loaded?

        event_schema.events.each do |event_name|
          schema = event_schema.latest_for(event_name)
          @schemas[event_name.to_sym] = schema
        end

        @loaded = true
        self
      end

      def current(event_name)
        @schemas.fetch(event_name.to_sym) do
          raise UnknownEventError, "Unknown event: #{event_name}"
        end
      end

      def loaded?
        @loaded == true
      end
    end
  end
end
