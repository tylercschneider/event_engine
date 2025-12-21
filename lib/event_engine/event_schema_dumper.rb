module EventEngine
  class EventSchemaDumper
    def self.dump!(definitions:, path:)
      compiled = DslCompiler.compile(definitions)
      compiled.finalize!

      file_schema = EventSchemaLoader.load(path)
      merged_schema = EventSchemaMerger.merge(compiled, file_schema)

      EventSchemaWriter.write(path, merged_schema)
    end
  end
end
