module EventEngine
  class EventSchemaDumper
    def self.dump(definitions:, path:)
      compiled = DslCompiler.compile(definitions)
      compiled.finalize!

      file_registry = EventSchemaLoader.load(path)
      merged = EventSchemaMerger.merge(compiled, file_registry)

      EventSchemaWriter.write(path, merged)
    end
  end
end
