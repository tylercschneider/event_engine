module EventEngine
  class EventEmitter
    def self.emit(event_name:, data:, version: nil, occurred_at: nil, metadata: nil)
      unless EventRegistry.loaded?
        raise EventRegistry::RegistryFrozenError, "EventRegistry must be loaded before emitting events"
      end

      schema = EventRegistry.schema(event_name, version: version)
      attrs  = EventBuilder.build(schema: schema, data: data)

      attrs[:occurred_at] = occurred_at || Time.current
      attrs[:metadata]    = metadata

      event = OutboxWriter.write(attrs)

      Delivery.enqueue do
        OutboxPublisher.new(
          transport: EventEngine.configuration.transport,
          batch_size: EventEngine.configuration.batch_size
        ).call
      end

      event
    end
  end
end
