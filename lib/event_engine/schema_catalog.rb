module EventEngine
  class SchemaCatalog
    def initialize(schema_registry:, subject_registry:)
      @schema_registry = schema_registry
      @subject_registry = subject_registry
    end

    def to_markdown
      (["# Event Catalog"] + event_sections).join("\n\n") + "\n"
    end

    private

    def event_sections
      @schema_registry.events.map do |event|
        schema = @schema_registry.latest_for(event)
        "## #{schema.event_name} (v#{schema.event_version})"
      end
    end
  end
end
