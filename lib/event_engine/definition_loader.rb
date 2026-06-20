module EventEngine
  module DefinitionLoader
    class << self
      def ensure_loaded!
        eager_load_definitions!
        LifecycleDefinition.materialize_all!
      end

      def eager_load_definitions!
        return if loaded?

        unless defined?(Rails) && Rails.application
          raise "EventEngine requires a Rails application to load definitions"
        end

        Rails.application.eager_load!

        @loaded = true
      end

      def loaded?
        @loaded ||= false
      end
    end
  end
end
