module EventEngine
  class EventSchema
    def self.define(&block)
      schema = new
      block.call(schema)
      schema
    end

    def initialize
      @schemas_by_event = {}
      @finalized = false
    end

    # Stores schemas by event_name => event_version => schema
    def register(schema)
      raise FrozenError, "EventSchema is finalized" if @finalized
      event_name = schema.event_name
      version = schema.event_version

      @schemas_by_event[event_name] ||= {}
      @schemas_by_event[event_name][version] = schema
    end

    def events
      @schemas_by_event.keys
    end

    def versions_for(event_name)
      versions = @schemas_by_event[event_name]
      return [] unless versions
      versions.keys.sort
    end

    def schema_for(event_name, version)
      @schemas_by_event.dig(event_name, version)
    end

    def latest_for(event_name)
      versions = @schemas_by_event[event_name]
      return nil unless versions && !versions.empty?
      versions[versions.keys.max]
    end

    def finalize!
      @finalized = true
      @schemas_by_event.each_value(&:freeze)
      @schemas_by_event.freeze
      freeze
    end

    # Internal accessor for now
    def schemas_by_event
      @schemas_by_event
    end
  end
end
