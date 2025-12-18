module EventEngine
  class EventDefinition
    module Inputs
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def input(name)
          name = name.to_sym

          if inputs.include?(name)
            raise ArgumentError, "duplicate input: #{name}"
          end

          inputs << name

        end

        def inputs
          @inputs ||= []
        end
      end
    end
  end
end
