require "test_helper"

module EventEngine
  class EventDefinitionRequiredPayloadTest < ActiveSupport::TestCase
    class CowFed < EventDefinition
      event_name :cow_fed
      event_type :domain

      input :cow

      required_payload :cow_id, from: :id
    end

    test "compiles required payload field into schema" do
      schema = CowFed.schema
      field  = schema.payload_fields.first

      assert_equal :cow_id, field[:name]
      assert_equal true, field[:required]
      assert_equal :cow, field[:from]
      assert_equal :id, field[:attr]
    end

    test "raises error if required_payload has no from" do
      error = assert_raises(ArgumentError) do
        Class.new(EventDefinition) do
          event_name :bad_event
          event_type :domain
          input :cow
          required_payload :cow_id
        end
      end

      assert_match "from", error.message
    end
  end
end
