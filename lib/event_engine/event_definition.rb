module EventEngine
  class EventDefinition
    attr_reader :event_name, :event_type

    def initialize(event_name:, event_type:)
      raise ArgumentError, "event_name is required" if blank?(event_name)
      raise ArgumentError, "event_type is required" if blank?(event_type)

      @event_name = event_name
      @event_type = event_type
    end

    private

    def blank?(value)
      value.nil? || (value.respond_to?(:empty?) && value.empty?)
    end
  end
end
