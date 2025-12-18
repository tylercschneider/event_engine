module EventEngine
  class EventDefinition
    module Fields
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def required(name, from:)
          add_field(name, from: from, required: true)
        end

        def optional(name, from:)
          add_field(name, from: from, required: false)
        end

        def fields
          @fields ||= {}
        end

        private

        def add_field(name, from:, required:)
          name = name.to_sym

          if fields.key?(name)
            raise ArgumentError, "duplicate field: #{name}"
          end

          normalized_from = normalize_from(from)

          fields[name] = {
            from: normalized_from,
            required: required
          }
        end

        def normalize_from(from)
          case from
          when Array
            from.map(&:to_sym)
          when Symbol
            infer_from_symbol(from)
          else
            raise ArgumentError, "invalid from: #{from.inspect}"
          end
        end

        def infer_from_symbol(attr)
          if inputs.empty?
            [:arguments, attr]
          elsif inputs.length == 1
            [inputs.first, attr]
          else
            raise ArgumentError,
                  "ambiguous extraction path for :#{attr}; specify input explicitly"
          end
        end
      end
    end
  end
end
