module EventEngine
  class EventSchema
    def initialize
      @schemas_by_event = {}
    end

    # Stores schemas by event_name => event_version => schema
    def register(schema)
      event_name = schema.event_name
      version = schema.event_version

      @schemas_by_event[event_name] ||= {}
      @schemas_by_event[event_name][version] = schema
    end

    # Internal accessor for now
    def schemas_by_event
      @schemas_by_event
    end
  end
end
