module EventEngine
  class Configuration
    attr_accessor :delivery_adapter, :transport, :batch_size, :max_attempts

    def initialize
      @delivery_adapter = :inline
      @transport = nil
      @batch_size = 100
      @max_attempts = 5
    end
  end
end
