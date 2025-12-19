module EventEngine
  class EventDefinition
    module Schemas
      def self.included(base)
        base.extend ClassMethods
      end

      class Schema < Struct.new(
        :event_name,
        :event_version,
        :event_type,
        :required_inputs,
        :optional_inputs,
        :payload_fields,
        keyword_init: true
      )
        def to_ruby
          <<~RUBY.strip
            EventEngine::EventDefinition::Schema.new(
              event_name: #{event_name.inspect},
              event_version: #{event_version.inspect},
              event_type: #{event_type.inspect},
              required_inputs: #{required_inputs.inspect},
              optional_inputs: #{optional_inputs.inspect},
              payload_fields: [#{payload_fields.map { |h| ruby_hash(h) }.join(", ")}]
            )
          RUBY
        end

        private

        def ruby_hash(hash)
          inner = hash.map { |k, v| "#{k}: #{v.inspect}" }.join(", ")
          "{#{inner}}"
        end
      end

      module ClassMethods
        def schema
          errors = schema_errors
          raise ArgumentError, errors.join(", ") if errors.any?

          required = inputs.select { |_, v| v== :required }.keys
          optional = inputs.select { |_, v| v== :optional }.keys

          Schema.new(
            event_name: @event_name,
            event_type: @event_type,
            required_inputs: required,
            optional_inputs: optional,
            payload_fields: payload_fields
          )
        end

        def schema_errors
          errors = []
          validate_identity(errors)
          validate_payload_fields(errors)
          errors
        end

        def valid_schema?
          schema_errors.empty?
        end

        private

        def validate_identity(errors)
          errors << "event_name is required" unless @event_name
          errors << "event_type is required" unless @event_type
        end

        def validate_payload_fields(errors)
          seen = {}

          payload_fields.each do |field|
            name = field[:name]

            if seen[name]
              errors << "duplicate payload field: #{name}"
            end

            if RESERVED_PAYLOAD_FIELDS.include?(name)
              errors << "payload field uses reserved name: #{name}"
            end

            if field[:from].nil?
              errors << "payload field #{name} must have a from:"
            end

            unless inputs.key?(field[:from])
              errors << "payload field #{name} references unknown input: #{field[:from]}"
            end

            if field[:attr].nil?
              errors << "payload field #{name} must have an attr:"
            end

            seen[name] = true
          end
        end
      end
    end
  end
end
