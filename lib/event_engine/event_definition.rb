require "event_engine/event_definition/inputs"
require "event_engine/event_definition/fields"
require "event_engine/event_definition/validation"

module EventEngine
  class EventDefinition
    include Inputs
    include Fields
    include Validation

    class Schema < Struct.new(
      :event_name, 
      :event_type,
      :required_inputs,
      :optional_inputs,
      :payload_fields,
      keyword_init: true
    )
    end

    class << self
      def event_name(value)
        @event_name = value
      end

      def event_type(value)
        @event_type = value
      end

      def schema
        raise ArgumentError, "event_name is required" unless @event_name
        raise ArgumentError, "event_type is required" unless @event_type

        required = inputs.select { |_, v| v== :required }.keys
        optional = inputs.select { |_, v| v== :optional }.keys

        Schema.new(
          event_name: @event_name,
          event_type: @event_type,
          required_inputs: required,
          optional_inputs: optional,
          payload_fields: payload_fields
        )
      end
    end

  end
end


# class CowFed < EventDefinition
#   input :cow

#   optional_input :farmer
#   optional_input :farm

#   event_name :cow_fed
#   event_type :domain

#   entity_class :class_name, from: :cow, type: :string
#   entity_id :id, from: :cow, type: :int
#   entity_version :version, from: :cow, type: :int

#   required_payload :weight, from: :cow, type: :float
#   optional_payload :name, from: :farmer, type: :string
# end


# bowling score - when where ball weight who with
# catan game - win / lose - score - played against
