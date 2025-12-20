require "event_engine/version"
require "event_engine/engine"
require "event_engine/outbox_publisher"
require "event_engine/transports/in_memory_transport"
require "event_engine/configuration"
require "event_engine/event_definition"
require "event_engine/event_emitter"
require "event_engine/event_registry"
require "event_engine/event_builder"
require "event_engine/outbox_writer"
require "event_engine/schema_snapshot"
require "event_engine/event_schema"

module EventEngine
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  def self.install_helpers(registry:)
    registry_event_names = registry.instance_variable_get(:@schemas).keys

    registry_event_names.each do |event_name|
      define_singleton_method(event_name) do |**data|
        EventEmitter.emit(event_name: event_name, data: data)
      end
    end
  end
end
