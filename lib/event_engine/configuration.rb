module EventEngine
  class Configuration
    class InvalidConfigurationError < StandardError; end

    attr_accessor :delivery_adapter, :transport, :batch_size, :max_attempts, :retention_period

    VALID_DELIVERY_ADAPTERS = %i[inline active_job].freeze

    def initialize
      @delivery_adapter = :inline
      @transport = nil
      @batch_size = 100
      @max_attempts = 5
      @retention_period = nil
    end

    def validate!
      unless VALID_DELIVERY_ADAPTERS.include?(delivery_adapter)
        raise InvalidConfigurationError,
          "Invalid delivery_adapter: #{delivery_adapter.inspect}. Must be one of: #{VALID_DELIVERY_ADAPTERS.join(', ')}"
      end

      if delivery_adapter == :active_job && transport.nil?
        raise InvalidConfigurationError,
          "Transport must be configured when using :active_job delivery adapter. " \
          "Set config.transport in your EventEngine initializer."
      end

      unless batch_size.is_a?(Integer) && batch_size > 0
        raise InvalidConfigurationError,
          "batch_size must be a positive integer, got: #{batch_size.inspect}"
      end

      unless max_attempts.is_a?(Integer) && max_attempts > 0
        raise InvalidConfigurationError,
          "max_attempts must be a positive integer, got: #{max_attempts.inspect}"
      end
    end
  end
end
