module EventEngine
  class OutboxPublisher
    def initialize(transport:)
      @transport = transport
    end

    def call
      OutboxEvent.unpublished.ordered.find_each do |event|
        begin
          @transport.publish(event)
          event.mark_published!
        rescue
          event.increment_attempts!
          raise
        end
      end
    end
  end
end
