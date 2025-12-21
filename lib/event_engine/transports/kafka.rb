module EventEngine
  module Transports
    class Kafka
      def initialize(producer:)
        @producer = producer
      end

      def publish(event)
        @producer.publish(topic_for(event), payload_for(event))
      end

      private

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
