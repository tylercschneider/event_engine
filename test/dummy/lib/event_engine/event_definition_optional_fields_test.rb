require "test_helper"

module EventEngine
  class EventDefinitionOptionalFieldsTest < ActiveSupport::TestCase
    test "allows declaring optional payload fields" do
      definition_class = Class.new(EventDefinition) do
        optional :weight_gain
        optional :feed_quality
      end

      optional_fields = definition_class.optional_fields

      assert_equal [:weight_gain, :feed_quality], optional_fields
    end

    test "does not allow duplicate optional fields" do
      error = assert_raises(ArgumentError) do
        Class.new(EventDefinition) do
          optional :weight_gain
          optional :weight_gain
        end
      end

      assert_match "duplicate optional field", error.message
    end
  end
end
