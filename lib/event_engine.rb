require "event_engine/version"
require "event_engine/engine"
require "event_engine/outbox_publisher"
require "event_engine/transports/in_memory_transport"
require "event_engine/configuration"
require "event_engine/event_definition"
require "event_engine/event_emitter"
require "event_engine/event_registry"
require "event_engine/event_builder"

module EventEngine
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  # def self.install_helpers(registry:)
  #   registry.current_schemas.each do |event_name, entry|
  #     schema = entry[:schema]

  #     define_singleton_method(event_name) do |**kwargs|
  #       attrs = EventBuilder.build(schema: schema, data: kwargs)
  #       Event.emit(attrs)
  #     end
  #   end
  # end
end
