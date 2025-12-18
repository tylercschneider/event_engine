require "event_engine/event_definition/inputs"

module EventEngine
  class EventDefinition
    include Inputs

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

    class << self
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

        normalized_from = normalize_from(from)

        fields[name] = {
          from: normalized_from,
          required: required
        }
      end

      def normalize_from(from)
        case from
        when Array
          from.map(&:to_sym)
        when Symbol
          infer_from_symbol(from)
        else
          raise ArgumentError, "invalid from: #{from.inspect}"
        end
      end

      def infer_from_symbol(attr)
        if inputs.empty?
          [:arguments, attr]
        elsif inputs.length == 1
          [inputs.first, attr]
        else
          raise ArgumentError,
                "ambiguous extraction path for :#{attr}; specify input explicitly"
        end
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
