require "test_helper"

module EventEngine
  class EventDefinitionExtractionNormalizationTest < ActiveSupport::TestCase
    test "single input allows shorthand from syntax" do
      definition_class = Class.new(EventDefinition) do
        input :cow
        required :cow_id, from: :id
      end

      field = definition_class.fields[:cow_id]

      assert_equal [:cow, :id], field[:from]
    end

    test "zero inputs treat from as arguments" do
      definition_class = Class.new(EventDefinition) do
        required :severity, from: :severity
      end

      field = definition_class.fields[:severity]

      assert_equal [:arguments, :severity], field[:from]
    end

    test "multiple inputs require explicit from path" do
      error = assert_raises(ArgumentError) do
        Class.new(EventDefinition) do
          input :cow
          input :farmer
          required :cow_id, from: :id
        end
      end

      assert_match "ambiguous extraction path", error.message
    end
  end
end
