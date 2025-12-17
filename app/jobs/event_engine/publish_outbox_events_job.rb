module EventEngine
  class PublishOutboxEventsJob < ApplicationJob
    queue_as :default

    def perform(transport:)
      OutboxPublisher.new(transport: transport).call
    end
  end
end
