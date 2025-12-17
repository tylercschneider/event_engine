module EventEngine
  class OutboxPublisher
    def initialize(transport:, batch_size: nil)
      @transport = transport
      @batch_size = batch_size
    end

    def call
      scope = OutboxEvent.unpublished.ordered
      scope = scope.limit(@batch_size) if @batch_size

      scope.find_each do |event|
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
