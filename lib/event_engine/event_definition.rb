module EventEngine
  class EventDefinition
    attr_reader :event_name, :event_type

    def initialize(event_name:, event_type:)
      raise ArgumentError, "event_name is required" if blank?(event_name)
      raise ArgumentError, "event_type is required" if blank?(event_type)

      @event_name = event_name
      @event_type = event_type
    end

    class << self
      def input(name)
        name = name.to_sym
        if inputs.include?(name)
          raise ArgumentError, "duplicate input: #{name}"
        end
        inputs << name
      end

      def inputs
        @inputs ||= []
      end

      def optional(name)
        name = name.to_sym
        if optional_fields.include?(name)
          raise ArgumentError, "duplicate optional field: #{name}"
        end
        optional_fields << name
      end

      def optional_fields
        @optional_fields ||= []
      end

      def required(name)
        name = name.to_sym
        if required_fields.include?(name)
          raise ArgumentError, "duplicate required field: #{name}"
        end
        required_fields << name
      end

      def required_fields
        @required_fields ||= []
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
