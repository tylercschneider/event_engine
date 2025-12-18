module EventEngine
  class EventDefinition
    module Fields
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def optional_payload(name, from: nil, attr: nil)
          payload_fields << {
            name: name.to_sym,
            required: false,
            from: resolve_from(from, attr),
            attr: resolve_attr(from, attr)
          }
        end

        def required_payload(name, from: nil, attr: nil)
          payload_fields << {
            name: name.to_sym,
            required: true,
            from: resolve_from(from, attr),
            attr: resolve_attr(from, attr)
          }
        end

        def payload_fields
          @payload_fields ||= []
        end

        def resolve_from(from, attr)
          return from if from && attr
          return sole_input if from && !attr
          raise ArgumentError, "from: is required for payload field"
        end

        def resolve_attr(from, attr)
          return attr if attr
          return from if from && sole_input
          raise ArgumentError, "attr cannot be resolved"
        end

        def sole_input
          all_inputs = inputs.keys
          raise ArgumentError, "ambiguous input for payload field" unless all_inputs.size == 1
          all_inputs.first
        end
      end
    end
  end
end
