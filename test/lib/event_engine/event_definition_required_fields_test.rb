require "test_helper"

module EventEngine
  class EventDefinitionRequiredFieldsTest < ActiveSupport::TestCase
    test "allows declaring required payload fields" do
      definition_class = Class.new(EventDefinition) do
        required :cow_id, from: :cow
        required :feed_type, from: :food
      end

      required_fields = definition_class.fields

      assert_equal [:cow_id, :feed_type], required_fields.keys  
    end

    test "does not allow duplicate required fields" do
      error = assert_raises(ArgumentError) do
        Class.new(EventDefinition) do
          required :cow_id, from: :cow
          required :cow_id, from: :cow
        end
      end

      assert_match "duplicate field: cow_id", error.message
    end
  end
end
