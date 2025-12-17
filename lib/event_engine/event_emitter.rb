module EventEngine
  class EventEmitter
    def self.emit(definition:, payload:)
      OutboxEvent.create!(
        event_name: definition.event_name,
        event_type: definition.event_type,
        payload: payload
      )
    end
  end
end
