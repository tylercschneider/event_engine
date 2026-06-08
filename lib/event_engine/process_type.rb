module EventEngine
  module ProcessType
    ALL = %i[inline background durable broker telemetry sourced].freeze

    PROCESSORS = {
      inline: :subscribers,
      background: :subscribers,
      durable: :delivery,
      broker: :delivery,
      telemetry: :telemetry,
      sourced: :sourcing
    }.freeze

    def self.all
      ALL
    end

    def self.processor_for(type)
      PROCESSORS[type]
    end

    def self.known?(type)
      ALL.include?(type)
    end

    LEGACY_EVENT_LEVELS = {
      1 => :inline,
      2 => :background,
      3 => :durable,
      4 => :broker,
      5 => :sourced
    }.freeze

    def self.from_event_level(level)
      LEGACY_EVENT_LEVELS[level]
    end
  end
end
