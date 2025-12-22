module EventEngine
  class EventSchemaWriter
    HEADER = <<~RUBY.freeze
      # This file is authoritative in production.
      # It is generated from EventDefinitions via:
      #
      #   bin/rails event_engine:schema_dump
      #
      # Do not edit manually.
    RUBY

    def self.write(path, event_schema)
      schemas =
        event_schema
          .schemas_by_event
          .flat_map { |_event, versions| versions.values }
          .sort_by { |s| [s.event_name.to_s, s.event_version] }

      File.open(path, "w") do |f|
        f.puts HEADER
        f.puts
        f.puts "EventEngine::EventSchema.define do |schema|"

        schemas.each do |event_schema|
          f.puts "  schema.register("
          f.puts "    #{event_schema.to_ruby}"
          f.puts "  )"
        end

        f.puts "end"
      end
    end
  end
end
