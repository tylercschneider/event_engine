module EventEngine
  module Cloud
    class Batch
      def initialize(max_size:)
        @max_size = max_size
        @entries = []
        @mutex = Mutex.new
      end

      def push(entry)
        @mutex.synchronize do
          @entries << entry
          @entries.size
        end
      end

      def drain
        @mutex.synchronize do
          entries = @entries.dup
          @entries.clear
          entries
        end
      end

      def full?
        @mutex.synchronize { @entries.size >= @max_size }
      end

      def size
        @mutex.synchronize { @entries.size }
      end
    end
  end
end
