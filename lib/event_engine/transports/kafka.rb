module EventEngine
  module Transports
    class Kafka
      def initialize(producer:, max_attempts: 5)
        @producer = producer
        @max_attempts = max_attempts
      end

      def publish(outbox_events)
        outbox_events.each do |event|
          publish_event(event)
        end
      end

      private

      def publish_event(event)
        @producer.publish(topic_for(event), payload_for(event))
        event.update!(published_at: Time.current)
      rescue => _
        handle_failure(event)
      end

      def handle_failure(event)
        event.increment!(:attempts)

        if event.attempts >= @max_attempts
          event.update!(dead_lettered_at: Time.current)
        end
      end

      def topic_for(event)
        "events.#{event.event_name}"
      end

      def payload_for(event)
        {
          event_name: event.event_name,
          event_type: event.event_type,
          event_version: event.event_version,
          payload: event.payload,
          metadata: event.metadata,
          occurred_at: event.occurred_at
        }
      end
    end
  end
end
