module EventEngine
  module Cloud
    class Reporter
      class << self
        def instance
          @instance ||= new
        end

        def reset!
          if @instance
            @instance.instance_variable_set(:@running, false)
            @instance = nil
          end
        end
      end

      def initialize
        @running = false
        @batch = nil
        @client = nil
        @mutex = Mutex.new
      end

      def start
        config = EventEngine.configuration
        @batch = Batch.new(max_size: config.cloud_batch_size)
        @client = ApiClient.new(
          api_key: config.cloud_api_key,
          endpoint: config.cloud_endpoint
        )
        @running = true

        logger.info("[EventEngine] Cloud Reporter started — reporting to #{config.cloud_endpoint}")
      end

      def shutdown
        return unless @running

        flush
        @running = false

        logger.info("[EventEngine] Cloud Reporter stopped")
      end

      def running?
        @running
      end

      def track_emit(entry)
        push(entry)
      end

      def track_publish(entry)
        push(entry)
      end

      def track_dead_letter(entry)
        push(entry)
      end

      def flush
        return unless @batch

        entries = @batch.drain
        return if entries.empty?

        @client.send_batch(entries)
      rescue StandardError => e
        EventEngine.configuration.logger.error(
          "[EventEngine::Cloud] Flush failed: #{e.class} - #{e.message}"
        )
      end

      def batch_size
        @batch&.size || 0
      end

      private

      def push(entry)
        return unless @running && @batch

        @batch.push(entry)
        flush if @batch.full?
      end

      def logger
        EventEngine.configuration.logger
      end
    end
  end
end
