module EventEngine
  module Cloud
    class Serializer
      def self.serialize_emit(notification_payload)
        {
          event_id: notification_payload[:event_id],
          event_name: notification_payload[:event_name],
          event_version: notification_payload[:event_version],
          idempotency_key: notification_payload[:idempotency_key],
          status: "emitted",
          timestamp: Time.current.iso8601
        }
      end

      def self.serialize_publish(notification_payload)
        {
          event_id: notification_payload[:event_id],
          event_name: notification_payload[:event_name],
          event_version: notification_payload[:event_version],
          status: "published",
          timestamp: Time.current.iso8601
        }
      end

      def self.serialize_dead_letter(notification_payload)
        {
          event_id: notification_payload[:event_id],
          event_name: notification_payload[:event_name],
          event_version: notification_payload[:event_version],
          status: "dead_lettered",
          attempts: notification_payload[:attempts],
          error_message: notification_payload[:error_message],
          error_class: notification_payload[:error_class],
          timestamp: Time.current.iso8601
        }
      end
    end
  end
end
