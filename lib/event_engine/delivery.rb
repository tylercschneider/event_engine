module EventEngine
  module Delivery
    def self.enqueue(&block)
      adapter = EventEngine.configuration.delivery_adapter || :inline

      case adapter
      when :inline
        yield if block_given?
      when :active_job
        PublishOutboxEventsJob.perform_later
      else
        raise ArgumentError, "Unknown delivery adapter: #{adapter}"
      end
    end
  end
end
