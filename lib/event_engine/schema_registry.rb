module EventEngine
  class SchemaRegistry
    def initialize(event_schema = EventSchema.new)
      @event_schema = event_schema
    end

    def register(schema)
      @event_schema.register(schema)
    end

    def events
      @event_schema.events
    end

    def versions_for(event_name)
      @event_schema.versions_for(event_name)
    end

    def schema_for(event_name, version)
      @event_schema.schema_for(event_name, version)
    end

    def latest_for(event_name)
      @event_schema.latest_for(event_name)
    end

    def event_schema
      @event_schema
    end

    def finalize!
      @event_schema.finalize!
    end
  end
end
