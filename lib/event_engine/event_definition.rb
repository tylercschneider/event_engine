require "event_engine/event_definition/inputs"
require "event_engine/event_definition/fields"

module EventEngine
  class EventDefinition
    include Inputs
    include Fields

    attr_reader :event_name, :event_type

    def initialize(event_name:, event_type:)
      raise ArgumentError, "event_name is required" if blank?(event_name)
      raise ArgumentError, "event_type is required" if blank?(event_type)

      @event_name = event_name
      @event_type = event_type
    end

    def validate_inputs!(inputs)
      declared = self.class.inputs
      provided = inputs.keys.map(&:to_sym)

      if declared.any?
        missing = declared - provided
        unless missing.empty?
          raise ArgumentError, "missing input: #{missing.join(', ')}"
        end

        extra = provided - declared
        unless extra.empty?
          raise ArgumentError, "undeclared input: #{extra.join(', ')}"
        end
      end
    end

    def payload
      value = build_payload

      unless value.is_a?(Hash)
        raise ArgumentError, "payload must be a Hash"
      end

      value
    end

    def to_outbox_attributes
      {
        event_name: event_name,
        event_type: event_type,
        payload: payload
      }
    end

    private

    def blank?(value)
      value.nil? || (value.respond_to?(:empty?) && value.empty?)
    end
    
    def build_payload
      nil
    end
  end
end
