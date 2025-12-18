require "event_engine/event_definition/inputs"
require "event_engine/event_definition/fields"
require "event_engine/event_definition/validation"

module EventEngine
  class EventDefinition
    include Inputs
    include Fields
    include Validation

    # def self.schema
    # end
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
