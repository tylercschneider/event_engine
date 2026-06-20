module EventEngine
  class DslCompiler
    class InvalidEventNameError < StandardError; end

    SNAKE_CASE = /\A[a-z][a-z0-9_]*\z/

    def self.compile(definitions)
      registry = SchemaRegistry.new
      subject_violations = []
      name_violations = []

      Array(definitions).each do |definition|
        schema = definition.schema
        record_subject_violation(schema, subject_violations)
        record_name_violation(schema, name_violations)
        registry.register(schema)
      end

      raise_invalid_event_names(name_violations)
      raise_unknown_subjects(subject_violations)

      registry
    end

    def self.record_name_violation(schema, violations)
      return if schema.event_name.to_s.match?(SNAKE_CASE)

      violations << schema.event_name.inspect
    end

    def self.raise_invalid_event_names(violations)
      return if violations.empty?

      raise InvalidEventNameError, "event names must be snake_case: #{violations.join(", ")}"
    end

    def self.record_subject_violation(schema, violations)
      return if schema.subject.nil?
      return if EventEngine.subject_registry.registered?(schema.subject)

      violations << "#{schema.event_name}: unknown subject #{schema.subject.inspect}"
    end

    def self.raise_unknown_subjects(violations)
      return if violations.empty?

      raise SubjectRegistry::UnknownSubjectError, violations.join(", ")
    end
  end
end
