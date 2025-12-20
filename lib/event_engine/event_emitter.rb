module EventEngine
  class EventEmitter
    def self.emit(event_name:, data:)
      unless EventRegistry.loaded?
        raise EventRegistry::RegistryFrozenError, "EventRegistry must be loaded before emitting events"
      end

      schema = EventRegistry.schema(event_name)
      attrs  = EventBuilder.build(schema: schema, data: data)
      attrs[:event_version] = 1
      OutboxWriter.write(attrs)
    end
  end
end
