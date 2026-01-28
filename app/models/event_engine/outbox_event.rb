module EventEngine
  class OutboxEvent < ApplicationRecord
    self.table_name = "event_engine_outbox_events"

    validates :event_name, presence: true
    validates :event_type, presence: true
    validates :payload, presence: true
    validates :idempotency_key, uniqueness: true, allow_nil: true

    scope :active, -> { where(dead_lettered_at: nil) }
    scope :dead_lettered, -> { where.not(dead_lettered_at: nil) }
    scope :ordered, -> { order(:created_at) }
    scope :retryable, ->(max_attempts) { where("attempts < ?", max_attempts) }
    scope :unpublished, -> { where(published_at: nil) }
    scope :published_before, ->(time) { where("published_at < ?", time) }
    scope :cleanable, -> { where.not(published_at: nil).where(dead_lettered_at: nil) }

    def dead_letter!
      update!(dead_lettered_at: Time.current)
    end

    def dead_lettered?
      dead_lettered_at.present?
    end

    def retry!
      update!(attempts: 0, dead_lettered_at: nil)
    end

    def increment_attempts!
      update!(attempts: (attempts || 0) + 1)
    end

    def mark_published!
      update!(published_at: Time.current)
    end
  end
end
