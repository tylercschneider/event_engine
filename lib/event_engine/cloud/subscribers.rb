module EventEngine
  module Cloud
    class Subscribers
      class << self
        def subscribe!(reporter:)
          @subscriptions = []
          @reporter = reporter

          @subscriptions << ActiveSupport::Notifications.subscribe("event_engine.event_emitted") do |*, payload|
            entry = Serializer.serialize_emit(payload)
            @reporter.track_emit(entry)
          end

          @subscriptions << ActiveSupport::Notifications.subscribe("event_engine.event_published") do |*, payload|
            entry = Serializer.serialize_publish(payload)
            @reporter.track_publish(entry)
          end

          @subscriptions << ActiveSupport::Notifications.subscribe("event_engine.event_dead_lettered") do |*, payload|
            entry = Serializer.serialize_dead_letter(payload)
            @reporter.track_dead_letter(entry)
          end
        end

        def unsubscribe!
          return unless @subscriptions

          @subscriptions.each do |subscription|
            ActiveSupport::Notifications.unsubscribe(subscription)
          end
          @subscriptions = nil
          @reporter = nil
        end
      end
    end
  end
end
