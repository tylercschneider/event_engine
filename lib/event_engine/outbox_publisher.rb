module EventEngine
  class OutboxPublisher
    def initialize(transport:, batch_size: nil, max_attempts: nil)
      @transport = transport
      @batch_size = batch_size
      @max_attempts = max_attempts
    end

    def call
      scope = OutboxEvent.unpublished
                        .active
                        .ordered
      scope = scope.retryable(@max_attempts) if @max_attempts
      scope = scope.limit(@batch_size) if @batch_size

      scope.find_each do |event|
        begin
          @transport.publish(event)
          event.mark_published!
        rescue => e
          event.increment_attempts!
          if @max_attempts && event.attempts >= @max_attempts
            event.dead_letter!
            Rails.logger.error(
              "[EventEngine] Dead-lettered event: event_id=#{event.id}, event_type=#{event.event_type}, attempts=#{event.attempts}, error=#{e.message}"
            )
          end
        end
      end
    end
  end
end
