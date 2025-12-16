module EventEngine
  class OutboxEvent < ApplicationRecord
    self.table_name = "event_engine_outbox_events"
  end
end
