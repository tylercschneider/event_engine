require "test_helper"

module EventEngine
  class EventDefinitionRequiredFieldsTest < ActiveSupport::TestCase
    test "allows declaring required payload fields" do
      definition_class = Class.new(EventDefinition) do
        required :cow_id
        required :feed_type
      end

      required_fields = definition_class.required_fields

      assert_equal [:cow_id, :feed_type], required_fields
    end

    test "does not allow duplicate required fields" do
      error = assert_raises(ArgumentError) do
        Class.new(EventDefinition) do
          required :cow_id
          required :cow_id
        end
      end

      assert_match "duplicate required field", error.message
    end
  end
end
