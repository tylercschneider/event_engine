module EventEngine
  class OutboxEvent < ApplicationRecord
    self.table_name = "event_engine_outbox_events"

    validates :event_name, presence: true
    validates :event_type, presence: true
    validates :payload, presence: true
    validates :idempotency_key, uniqueness: true, allow_nil: true

    scope :ordered, -> { order(:created_at) }
    scope :unpublished, -> { where(published_at: nil) }

    def mark_published!
      update!(published_at: Time.current)
    end
  end
end
