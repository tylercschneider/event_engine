module EventEngine
  class OutboxPublisher
    def initialize(transport:)
      @transport = transport
    end

    def call
      OutboxEvent.unpublished.ordered.find_each do |event|
        @transport.publish(event)
        event.mark_published!
      end
    end
  end
end
