module EventEngine
  class SchemaCatalog
    def initialize(schema_registry:, subject_registry:)
      @schema_registry = schema_registry
      @subject_registry = subject_registry
    end

    def to_markdown
      "# Event Catalog\n"
    end
  end
end
