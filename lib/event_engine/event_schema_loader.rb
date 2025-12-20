module EventEngine
  class EventSchemaLoader
    def self.load(path)
      registry = FileLoadedRegistry.new
      return registry unless File.exist?(path)

      schema = nil

      schema = Module.new.module_eval(File.read(path), path)
      
      if schema
        schema.schemas_by_event.each_value do |versions|
          versions.each_value do |s|
            registry.register(s)
          end
        end
      end

      registry
    end
  end
end
