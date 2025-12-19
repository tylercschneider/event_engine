module EventEngine
  class EventRegistry
    class << self
      def reset!
        @schemas = {}
      end

      def register(event_definition_class)
        schema = event_definition_class.schema
        schemas[schema.event_name] = schema
      end

      def current(event_name)
        schemas.fetch(event_name.to_sym)
      end

      private

      def schemas
        @schemas ||= {}
      end
    end
  end
end
