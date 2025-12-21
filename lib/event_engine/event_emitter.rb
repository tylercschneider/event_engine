module EventEngine
  class EventEmitter
    def self.emit(event_name:, data:, version: nil)
      unless EventRegistry.loaded?
        raise EventRegistry::RegistryFrozenError, "EventRegistry must be loaded before emitting events"
      end

      schema = EventRegistry.schema(event_name, version: version)
      attrs  = EventBuilder.build(schema: schema, data: data)

      OutboxWriter.write(attrs)
    end
  end
end
