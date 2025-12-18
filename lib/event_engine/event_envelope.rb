module EventEngine
  class EventEnvelope
    def initialize(event_name:, event_type:, payload:)
      @event_name = event_name
      @event_type = event_type
      @payload = payload
    end

    def to_outbox_attributes
      {
        event_name: @event_name,
        event_type: @event_type,
        payload: @payload
      }
    end
  end
end
