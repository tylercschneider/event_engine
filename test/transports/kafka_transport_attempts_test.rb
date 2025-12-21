require "test_helper"

class KafkaTransportAttemptsTest < ActiveSupport::TestCase
  def test_increments_attempts_on_failure
    event = EventEngine::OutboxEvent.create!(
      event_name: "cow.fed",
      event_type: "domain",
      event_version: 1,
      payload: { amount: 5 },
      metadata: {},
      occurred_at: Time.current,
      attempts: 0
    )

    transport = EventEngine::Transports::Kafka.new(
      producer: FailingKafkaProducer.new,
      max_attempts: 3
    )

    transport.publish([event])

    event.reload
    assert_equal 1, event.attempts
    assert_nil event.published_at
    assert_nil event.dead_lettered_at
  end

  def test_dead_letters_event_after_max_attempts
    event = EventEngine::OutboxEvent.create!(
      event_name: "cow.fed",
      event_type: "domain",
      event_version: 1,
      payload: { amount: 5 },
      metadata: {},
      occurred_at: Time.current,
      attempts: 2
    )

    transport = EventEngine::Transports::Kafka.new(
      producer: FailingKafkaProducer.new,
      max_attempts: 3
    )

    transport.publish([event])

    event.reload
    assert_equal 3, event.attempts
    assert_not_nil event.dead_lettered_at
    assert_nil event.published_at
  end

  private

  class FailingKafkaProducer
    def publish(_topic, _payload)
      raise "broker unavailable"
    end
  end
end
