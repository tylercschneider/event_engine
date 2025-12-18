require "test_helper"

module EventEngine
  class EventDefinitionRequiredFieldsTest < ActiveSupport::TestCase
    # test "allows declaring required payload fields" do
    #   definition_class = Class.new(EventDefinition) do
    #     input :cow
    #     required_payload :cow_id, from: :cow
    #     required_payload :feed_type, from: :food
    #   end

    #   required_fields = definition_class.fields

    #   assert_equal [:cow_id, :feed_type], required_fields.keys  
    # end

    # test "does not allow duplicate required fields" do
    #   error = assert_raises(ArgumentError) do
    #     Class.new(EventDefinition) do
    #       required_payload :cow_id, from: :cow
    #       required_payload :cow_id, from: :cow
    #     end
    #   end

    #   assert_match "duplicate field: cow_id", error.message
    # end
  end
end
