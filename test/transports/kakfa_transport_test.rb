require "test_helper"

class KafkaTransportTest < ActiveSupport::TestCase
  def test_publishes_events_and_marks_them_published
    event = EventEngine::OutboxEvent.create!(
      event_name: "cow.fed",
      event_type: "domain",
      event_version: 1,
      payload: { amount: 5 },
      metadata: {},
      occurred_at: Time.current
    )

    transport = EventEngine::Transports::Kafka.new(
      producer: FakeKafkaProducer.new
    )

    transport.publish([event])

    event.reload
    assert_not_nil event.published_at
  end

  private

  class FakeKafkaProducer
    def publish(_topic, _payload)
      true
    end
  end
end
