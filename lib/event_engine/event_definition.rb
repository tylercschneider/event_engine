require "event_engine/event_definition/inputs"
require "event_engine/event_definition/fields"
require "event_engine/event_definition/validation"

module EventEngine
  class EventDefinition
    include Inputs
    include Fields
    include Validation
  end
end
