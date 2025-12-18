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
        add_to_schema_list(:inputs, name, "input")
      end

      def inputs
        @inputs ||= []
      end

      def required(name, from:)
        add_field(name, from: from, required: true)
      end

      def optional(name, from:)
        add_field(name, from: from, required: false)
      end

      def fields
        @fields ||= {}
      end

      private

      def add_field(name, from:, required:)
        name = name.to_sym

        if fields.key?(name)
          raise ArgumentError, "duplicate field: #{name}"
        end

        fields[name] = {
          from: Array(from),
          required: required
        }
      end

      def add_to_schema_list(list_name, name, label)
        name = name.to_sym
        list = send(list_name)

        if list.include?(name)
          raise ArgumentError, "duplicate #{label}: #{name}"
        end

        list << name
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
