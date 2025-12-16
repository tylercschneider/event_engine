module EventEngine
  class OutboxEvent < ApplicationRecord
    self.table_name = "event_engine_outbox_events"

    validates :event_name, presence: true
    validates :event_type, presence: true
  end
end
