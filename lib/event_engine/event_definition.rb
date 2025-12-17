module EventEngine
  class EventDefinition
    attr_reader :event_name, :event_type

    def initialize(event_name:, event_type:)
      @event_name = event_name
      @event_type = event_type
    end
  end
end
