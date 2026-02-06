module EventEngine
  module Transports
    class NullTransport
      def publish(event)
        logger.warn("[EventEngine::NullTransport] Event '#{event.event_name}' discarded. No transport configured.")
        true
      end

      private

      def logger
        EventEngine.configuration.logger
      end
    end
  end
end
