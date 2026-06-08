module EventEngine
  module ProcessType
    ALL = %i[inline background durable broker telemetry sourced].freeze

    def self.all
      ALL
    end
  end
end
