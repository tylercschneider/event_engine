require "test_helper"

module EventEngine
  class EventDefinitionPayloadTest < ActiveSupport::TestCase
    # test "builds payload from single input" do
    #   cow = Struct.new(:id, :weight_gain).new(123, 10)

    #   definition = Class.new(EventDefinition) do
    #     input :cow
    #     required :cow_id, from: :id
    #     optional :weight_gain, from: :weight_gain
    #   end.new(
    #     event_name: "cow.fed",
    #     event_type: "domain"
    #   )

    #   attributes = definition.to_outbox_attributes(cow: cow)

    #   assert_equal(
    #     {
    #       event_name: "cow.fed",
    #       event_type: "domain",
    #       payload: {
    #         cow_id: 123,
    #         weight_gain: 10
    #       }
    #     },
    #     attributes
    #   )
    # end

    # test "raises error when required field value is nil" do
    #   cow = Struct.new(:id).new(nil)

    #   definition = Class.new(EventDefinition) do
    #     input :cow
    #     required :cow_id, from: :id
    #   end.new(
    #     event_name: "cow.fed",
    #     event_type: "domain"
    #   )

    #   error = assert_raises(ArgumentError) do
    #     definition.to_outbox_attributes(cow: cow)
    #   end

    #   assert_match "missing required field", error.message
    # end

    # test "omits optional field when value is nil" do
    #   cow = Struct.new(:id, :weight_gain).new(123, nil)

    #   definition = Class.new(EventDefinition) do
    #     input :cow
    #     required :cow_id, from: :id
    #     optional :weight_gain, from: :weight_gain
    #   end.new(
    #     event_name: "cow.fed",
    #     event_type: "domain"
    #   )

    #   attributes = definition.to_outbox_attributes(cow: cow)

    #   assert_equal({ cow_id: 123 }, attributes[:payload])
    # end

    # test "builds payload for zero-input event from arguments" do
    #   definition = Class.new(EventDefinition) do
    #     required :severity, from: :severity
    #   end.new(
    #     event_name: "gums.bled",
    #     event_type: "health"
    #   )

    #   attributes = definition.to_outbox_attributes(severity: "light")

    #   assert_equal(
    #     {
    #       event_name: "gums.bled",
    #       event_type: "health",
    #       payload: { severity: "light" }
    #     },
    #     attributes
    #   )
    # end
  end
end
