require "test_helper"

module EventEngine
  class EventDefinitionOptionalFieldsTest < ActiveSupport::TestCase
    # test "allows declaring optional payload fields" do
    #   definition_class = Class.new(EventDefinition) do
    #     optional :weight_gain, from: :health_data
    #     optional :feed_quality, from: :health_data
    #   end

    #   optional_fields = definition_class.fields

    #   assert_equal [:weight_gain, :feed_quality], optional_fields.keys
    # end

    # test "does not allow duplicate optional fields" do
    #   error = assert_raises(ArgumentError) do
    #     Class.new(EventDefinition) do
    #       optional :weight_gain, from: :health_data
    #       optional :weight_gain, from: :health_data
    #     end
    #   end

    #   assert_match "duplicate field: weight_gain", error.message
    # end
  end
end
