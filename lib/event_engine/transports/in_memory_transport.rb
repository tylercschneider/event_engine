module EventEngine
  module Transports
    class InMemoryTransport
      attr_reader :events

      def initialize
        @events = []
      end

      def publish(event)
        @events << event
        true
      end
    end
  end
end
