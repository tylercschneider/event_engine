module EventEngine
  class Configuration
    attr_accessor :transport, :batch_size, :max_attempts

    def initialize
      @batch_size = 100
      @max_attempts = 5
    end
  end
end
