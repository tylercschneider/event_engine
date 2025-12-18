require "test_helper"

module EventEngine
  class EventDefinitionInputValidationTest < ActiveSupport::TestCase
    # test "raises error when required input is missing" do
    #   definition = Class.new(EventDefinition) do
    #     input :cow
    #   end.new

    #   error = assert_raises(ArgumentError) do
    #     definition.validate_inputs!({})
    #   end

    #   assert_match "missing input", error.message
    # end

    # test "raises error when undeclared input is provided" do
    #   definition = Class.new(EventDefinition) do
    #     input :cow
    #   end.new

    #   error = assert_raises(ArgumentError) do
    #     definition.validate_inputs!(cow: Object.new, farmer: Object.new)
    #   end

    #   assert_match "undeclared input", error.message
    # end

    # test "allows zero-input events" do
    #   definition = Class.new(EventDefinition).new

    #   # Should not raise
    #   definition.validate_inputs!(severity: "light")
    # end
  end
end
