module EventEngine
  class EventEmitter
    def self.emit(event_name:, data:, registry:, version: nil, occurred_at: nil, metadata: nil, idempotency_key: nil)
      unless registry.loaded?
        raise SchemaRegistry::RegistryFrozenError, "EventRegistry must be loaded before emitting events"
      end

      schema = registry.schema(event_name, version: version)
      attrs  = EventBuilder.build(schema: schema, data: data)

      attrs[:occurred_at] = occurred_at || Time.current
      attrs[:metadata] = metadata
      attrs[:idempotency_key] = idempotency_key || SecureRandom.uuid

      event = OutboxWriter.write(attrs)

      Delivery.enqueue do
        transport = EventEngine.configuration.transport
        unless transport
          Rails.logger.warn("[EventEngine] No transport configured — event written to outbox but not published. " \
            "Set config.transport in your initializer to enable publishing.")
          next
        end

        OutboxPublisher.new(
          transport: transport,
          batch_size: EventEngine.configuration.batch_size
        ).call
      end

      event
    end
  end
end
