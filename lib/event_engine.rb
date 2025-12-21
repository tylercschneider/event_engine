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
require "event_engine/event_schema"
require "event_engine/compiled_schema_registry"
require "event_engine/file_loaded_registry"
require "event_engine/dsl_compiler"
require "event_engine/event_schema_loader"
require "event_engine/event_schema_writer"
require "event_engine/event_schema_merger"
require "event_engine/event_schema_dumper"

module EventEngine
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  def self.install_helpers(registry:)
    registry.events.each do |event_name|
      schema = registry.schema(event_name)

      required = schema.required_inputs
      optional = schema.optional_inputs

      define_singleton_method(event_name) do |**args|
        event_version = args.delete(:event_version)
        occurred_at = args.delete(:occurred_at)
        metadata = args.delete(:metadata)


        input_keys = required + optional
        inputs = args.slice(*input_keys)

        missing = required - inputs.keys
        if missing.any?
          raise ArgumentError, "Missing required inputs: #{missing.join(', ')}"
        end

        EventEmitter.emit(
          event_name: event_name,
          data: inputs,
          version: event_version,
          occurred_at: occurred_at,
          metadata: metadata
        )
      end
    end
  end
end
