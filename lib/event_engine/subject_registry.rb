module EventEngine
  # Registry of subjects: the capabilities or features a group of related events
  # describes. Declared once by the host app and used to validate that event
  # definitions reference a known subject.
  #
  # @example Declare subjects
  #   EventEngine::SubjectRegistry.define do
  #     subject :export_csv
  #     subject :feeding
  #   end
  class SubjectRegistry
    # A single registered subject.
    class Subject
      # @return [Symbol] the subject name
      attr_reader :name

      # @param name [Symbol]
      def initialize(name)
        @name = name
      end
    end

    # Builds a registry from a block of +subject+ declarations.
    #
    # @yield evaluated in the registry instance
    # @return [SubjectRegistry]
    def self.define(&block)
      registry = new
      registry.instance_eval(&block) if block
      registry
    end

    def initialize
      @subjects = {}
    end

    # Declares a subject.
    #
    # @param name [Symbol]
    # @return [Subject]
    def subject(name)
      @subjects[name] = Subject.new(name)
    end

    # Looks up a subject by name.
    #
    # @param name [Symbol]
    # @return [Subject, nil]
    def [](name)
      @subjects[name]
    end
  end
end
