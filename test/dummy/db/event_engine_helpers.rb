# This file is authoritative in production.
# It is generated from EventDefinitions via:
#
#   bin/rails event_engine:schema:dump
#
# Do not edit manually.

module EventEngine
  class << self
    def widget_created(widget:, event_version: nil, occurred_at: nil, metadata: nil, idempotency_key: nil, aggregate_type: nil, aggregate_id: nil, aggregate_version: nil)
      emit(:widget_created, inputs: { widget: widget }, event_version: event_version, occurred_at: occurred_at, metadata: metadata, idempotency_key: idempotency_key, aggregate_type: aggregate_type, aggregate_id: aggregate_id, aggregate_version: aggregate_version)
    end
  end
end
