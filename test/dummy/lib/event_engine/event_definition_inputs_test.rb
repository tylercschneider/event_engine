require "test_helper"

module EventEngine
  class EventDefinitionInputsTest < ActiveSupport::TestCase
    test "allows declaring named inputs" do
      definition_class = Class.new(EventDefinition) do
        input :cow
        input :farmer
      end

      inputs = definition_class.inputs

      assert_equal [:cow, :farmer], inputs
    end

    test "allows zero inputs" do
      definition_class = Class.new(EventDefinition)

      assert_equal [], definition_class.inputs
    end

    test "does not allow duplicate inputs" do
      error = assert_raises(ArgumentError) do
        Class.new(EventDefinition) do
          input :cow
          input :cow
        end
      end

      assert_match "duplicate input", error.message
    end
  end
end
