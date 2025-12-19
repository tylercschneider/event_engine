module EventEngine
  class EventDefinition
    module Payloads
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def optional_payload(name, from: nil, attr: nil)
          payload_fields << {
            name: name.to_sym,
            required: false,
            from: resolve_from(name, from),
            attr: resolve_attr(name, attr)
          }
        end

        def required_payload(name, from: nil, attr: nil)
          payload_fields << {
            name: name.to_sym,
            required: true,
            from: resolve_from(name, from),
            attr: resolve_attr(name, attr)
          }
        end

        def payload_fields
          @payload_fields ||= []
        end

        def resolve_from(name, from)
          return from if from
          raise ArgumentError, "from: is required for payload #{name}"
        end

        def resolve_attr(name, attr)
          return attr if attr
          raise ArgumentError, "attr: is required for payload #{name}"
        end
      end
    end
  end
end
