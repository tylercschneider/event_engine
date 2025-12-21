require "test_helper"

class KafkaTransportTest < ActiveSupport::TestCase
  def test_publishes_event_payload_to_producer
    event = EventEngine::OutboxEvent.new(
      event_name: "cow.fed",
      event_type: "domain",
      event_version: 1,
      payload: { amount: 5 },
      metadata: {},
      occurred_at: Time.current
    )

    producer = FakeKafkaProducer.new
    transport = EventEngine::Transports::Kafka.new(producer: producer)

    transport.publish(event)

    assert_equal 1, producer.published.size
    published = producer.published.first

    assert_equal "events.cow.fed", published[:topic]
    assert_equal "cow.fed", published[:payload][:event_name]
  end

  private

  class FakeKafkaProducer
    attr_reader :published

    def initialize
      @published = []
    end

    def publish(topic, payload)
      @published << { topic:, payload: }
    end
  end
end
