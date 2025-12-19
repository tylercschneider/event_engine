require "event_engine/event_definition/inputs"
require "event_engine/event_definition/payloads"
require "event_engine/event_definition/validation"
require "event_engine/event_definition/schemas"

module EventEngine
  class EventDefinition
    RESERVED_PAYLOAD_FIELDS = %i[event_name event_type].freeze

    include Inputs
    include Payloads
    include Validation
    include Schemas

    class << self
      def event_name(value)
        @event_name = value
      end

      def event_type(value)
        @event_type = value
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
