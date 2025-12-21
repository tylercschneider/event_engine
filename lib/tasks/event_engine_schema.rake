namespace :event_engine do
  namespace :schema do
    desc "Regenerate event_schema.rb from EventDefinitions"
    task dump: :environment do
      EventEngine::EventSchemaDumper.dump!(
        definitions: EventEngine::EventDefinition.descendants,
        path: Rails.root.join("event_schema.rb")
      )
    end
  end
end
