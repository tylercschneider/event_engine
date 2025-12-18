module EventEngine
  class EventDefinition
    module Inputs
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def input(name)
          add_to_schema_list(:inputs, name, "input")
        end

        def inputs
          @inputs ||= []
        end
      end
    end
  end
end
