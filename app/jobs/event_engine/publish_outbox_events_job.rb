module EventEngine
  class PublishOutboxEventsJob < ApplicationJob
    queue_as :default

    def perform
      transport = EventEngine.configuration.transport
      raise "EventEngine transport not configured" unless transport

      OutboxPublisher.new(transport: transport).call
    end
  end
end
