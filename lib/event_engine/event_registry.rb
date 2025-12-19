module EventEngine
  class EventRegistry
    class UnknownEventError < StandardError; end
    class RegistryFrozenError < StandardError; end

    class << self
      def reset!
        @schemas = {}
        @loaded = false
      end

      def register(event_definition_class)
        raise RegistryFrozenError, "EventRegistry is already loaded" if loaded?
        schema = event_definition_class
        schemas[schema.event_name.to_sym] = schema
      end

      def current(event_name)
        schemas.fetch(event_name.to_sym) { raise UnknownEventError, "Unknown event: #{event_name}" }
      end

      def current_schema(event_name)
        current(event_name)
      end

      # Explicit boot-time load
      def load!(definitions: nil)
        raise RegistryFrozenError, "EventRegistry already loaded" if loaded?

        if block_given?
          raise ArgumentError, "cannot pass definitions and a block" if definitions
          yield self
        else
          discover!(definitions: definitions)
        end

        # Freeze schemas and registry storage
        schemas.each_value(&:freeze)
        schemas.freeze

        @loaded = true
        self
      end


      def loaded?
        @loaded
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

        defs.each { |klass| register(klass.schema) }
        self
      end


      private

      def schemas
        @schemas ||= {}
      end
    end
  end
end
