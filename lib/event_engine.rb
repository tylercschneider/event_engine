require "event_engine/version"
require "event_engine/engine"
require "event_engine/outbox_publisher"
require "event_engine/transports/in_memory_transport"
require "event_engine/configuration"
require "event_engine/event_definition"
require "event_engine/event_emitter"
require "event_engine/event_envelope"

module EventEngine
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end
end
