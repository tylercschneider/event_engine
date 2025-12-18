module EventEngine
  class Engine < ::Rails::Engine
    isolate_namespace EventEngine
    # initializer "event_engine.install_helpers" do
    #   EventEngine.install_helpers(registry: EventRegistry)
    # end
  end
end
