module EventEngine
  class EventRegistry
    class UnknownEventError < StandardError; end

    class << self
      def reset!
        @schemas = {}
      end

      def register(event_definition_class)
        schema = event_definition_class.schema
        schemas[schema.event_name.to_sym] = schema
      end

      def current(event_name)
        schemas.fetch(event_name.to_sym) { raise UnknownEventError, "Unknown event: #{event_name}" }
      end

      def current_schema(event_name)
        current(event_name)
      end

      # Deterministic discovery
      # - In prod: call without args after eager loading
      # - In tests: pass explicit definitions
      def discover!(definitions: nil)
        defs =
          if definitions
            Array(definitions)
          else
            EventEngine::EventDefinition.descendants
          end

        defs.each { |klass| register(klass) }
        self
      end


      private

      def schemas
        @schemas ||= {}
      end
    end
  end
end
