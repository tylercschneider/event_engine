module EventEngine
  class Engine < ::Rails::Engine
    isolate_namespace EventEngine

    initializer "event_engine.load_schema_and_install_helpers" do
      ActiveSupport.on_load(:after_initialize) do
        schema_path = Rails.root.join("db", "event_schema.rb")
        next unless File.exist?(schema_path)

        Engine.send(
          :load_schema_and_install_helpers,
          schema_path: schema_path
        )
      end
    end

    class << self
      private

      def load_schema_and_install_helpers(schema_path:)
        EventEngine.boot_from_schema!(schema_path: schema_path)
      end
    end
  end
end
