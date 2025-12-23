namespace :event_engine do
  desc "Fail if event schema DSL has drifted from db/event_schema.rb"
  task schema: :environment do
    EventEngine::SchemaDriftGuard.check!(
      schema_path: Rails.root.join("db/event_schema.rb"),
      definitions: EventEngine::EventDefinition.descendants
    )
  end

  namespace :schema do
    desc "Regenerate event_schema.rb from EventDefinitions"
    task dump: :environment do
      EventEngine::DefinitionLoader.ensure_loaded!

      descendants = EventEngine::EventDefinition.descendants
      if descendants.empty?
        raise <<~MSG
          EventEngine found no EventDefinitions.

          Expected definitions to be loaded during eager load.
          Ensure they live in an eager-load path (e.g. app/event_definitions).
        MSG
      end

      EventEngine::EventSchemaDumper.dump!(
        definitions: descendants,
        path: Rails.root.join("event_schema.rb")
      )
      puts "Dumping EventEngine schema to #{Rails.root.join("event_schema.rb")}"
    end
  end
end
