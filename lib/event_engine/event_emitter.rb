module EventEngine
  class EventEmitter
    def self.emit(definition:)
      OutboxEvent.create!(
        event_name: definition.event_name,
        event_type: definition.event_type,
        payload: definition.payload
      )
    end
  end
end
