# This file is authoritative in production.
# It is generated from EventDefinitions via:
#
#   bin/rails event_engine:schema:dump
#
# Do not edit manually.

EventEngine::EventSchema.define do |schema|
  schema.register(
    EventEngine::EventDefinition::Schema.new(

      event_name: :widget_created,

      event_version: 1,

      event_type: :domain,

      process_type: nil,

      subject: nil,

      domain: nil,

      required_inputs: [:widget],

      optional_inputs: [],

      payload_fields: [{name: :sku, required: true, from: :widget, attr: :sku}]

    )
  )
end
