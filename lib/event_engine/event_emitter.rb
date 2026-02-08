module EventEngine
  # Orchestrates event emission: validates inputs, builds the payload,
  # writes to the outbox, fires notifications, and enqueues delivery.
  #
  # @example
  #   EventEmitter.emit(event_name: :cow_fed, data: { cow: cow }, registry: registry)
  class EventEmitter
    # Emits an event through the full pipeline.
    #
    # @param event_name [Symbol] the event to emit
    # @param data [Hash] input data keyed by input name
    # @param registry [SchemaRegistry] the loaded schema registry
    # @param version [Integer, nil] specific schema version (nil for latest)
    # @param occurred_at [Time, nil] when the event occurred (defaults to now)
    # @param metadata [Hash, nil] optional contextual metadata
    # @param idempotency_key [String, nil] deduplication key (defaults to UUID)
    # @return [OutboxEvent] the persisted outbox event
    # @raise [SchemaRegistry::RegistryFrozenError] if registry is not loaded
    # @raise [SchemaRegistry::UnknownEventError] if event name is not registered
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

      ActiveSupport::Notifications.instrument("event_engine.event_emitted", {
        event_name: event.event_name,
        event_version: event.event_version,
        event_id: event.id,
        idempotency_key: event.idempotency_key
      })

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
