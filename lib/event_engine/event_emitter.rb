module EventEngine
  class EventEmitter
    def self.emit(event_name:, data:)
      # schema = EventRegistry.current(event_name)
      # attrs  = EventBuilder.build(
      #   schema: schema,
      #   data: data
      # )

      # OutboxWriter.write(attrs)
    end
  end
end
