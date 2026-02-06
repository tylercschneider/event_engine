module EventEngine
  module Delivery
    def self.enqueue(&block)
      adapter = EventEngine.configuration.delivery_adapter || :inline

      case adapter
      when :inline
        if block_given?
          if ActiveRecord::Base.connection.transaction_open?
            AfterCommitCallback.register(ActiveRecord::Base.connection, &block)
          else
            yield
          end
        end
      when :active_job
        PublishOutboxEventsJob.perform_later
      else
        raise ArgumentError, "Unknown delivery adapter: #{adapter}"
      end
    end

    class AfterCommitCallback
      def initialize(&block)
        @callback = block
      end

      def committed!(*)
        @callback.call
      end

      def before_committed!(*); end
      def rolledback!(*); end

      def trigger_transactional_callbacks?
        true
      end

      def has_transactional_callbacks?
        true
      end

      def self.register(connection, &block)
        connection.current_transaction.add_record(new(&block))
      end
    end
  end
end
