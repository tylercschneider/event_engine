module EventEngine
  class EventSchemaWriter
    def self.write(path, event_schema)
      schemas =
        event_schema
          .schemas_by_event
          .flat_map { |_event, versions| versions.values }
          .sort_by { |s| [s.event_name.to_s, s.event_version] }

      File.open(path, "w") do |f|
        f.puts "EventEngine::EventSchema.define do |schema|"

        schemas.each do |schema|
          f.puts "  schema.register("
          f.puts "    #{schema.to_ruby}"
          f.puts "  )"
        end

        f.puts "end"
      end
    end
  end
end
