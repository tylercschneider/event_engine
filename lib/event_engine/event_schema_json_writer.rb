require "json"

module EventEngine
  class EventSchemaJsonWriter
    def self.write(path, event_schema)
      schemas =
        event_schema
          .schemas_by_event
          .flat_map { |_event, versions| versions.values }
          .sort_by { |s| [s.event_name.to_s, s.event_version] }

      File.write(path, "#{JSON.pretty_generate(schemas.map(&:to_h))}\n")
    end
  end
end
