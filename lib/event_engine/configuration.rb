module EventEngine
  class Configuration
    attr_accessor :transport, :batch_size

    def initialize
      @batch_size = 100
    end
  end
end
