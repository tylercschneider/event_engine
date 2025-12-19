module EventEngine
  class EventRegistry
    class UnknownEventError < StandardError; end
    class RegistryFrozenError < StandardError; end

    class << self
      def reset!
        @schemas = {}
        @loaded = false
      end

      def register(schema)
        raise RegistryFrozenError, "EventRegistry is already loaded" if loaded?
        event_name = schema.event_name.to_sym

        version = schema.event_version || 1
        schema.event_version = 1

        schemas[event_name] ||= {}
        schemas[event_name][version] = schema
      end

      def all_schemas
        schemas
          .flat_map { |_name, versions| versions.values }
          .sort_by { |schema| [schema.event_name.to_s, schema.event_version] }
      end

      def schemas_by_event
        schemas
      end

      def current(event_name)
        schemas.fetch(event_name.to_sym) { raise UnknownEventError, "Unknown event: #{event_name}" }
      end

      def current_schema(event_name)
        versions = schemas.fetch(event_name.to_sym) do
          raise UnknownEventError, "Unknown event: #{event_name}"
        end

        versions[versions.keys.max]
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
        schemas.each_value do |versioned|
          versioned.each_value(&:freeze)
          versioned.freeze
        end

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
