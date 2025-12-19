require "test_helper"
require "ostruct"

module EventEngine
  class EventEmitterTest < ActiveSupport::TestCase
    class CowFed < EventDefinition
      event_name :cow_fed
      event_type :domain

      input :cow

      required_payload :weight, from: :cow, attr: :weight
    end

    setup do
      EventRegistry.reset!
      EventRegistry.register(CowFed)
    end

    test "emits an OutboxEvent via registry and builder" do
      cow = OpenStruct.new(weight: 500)

      event = EventEmitter.emit(
        event_name: :cow_fed,
        data: { cow: cow }
      )

      assert event.persisted?
      assert_equal "cow_fed", event.event_name
      assert_equal "domain", event.event_type
      assert_equal({ "weight" => 500 }, event.payload)
    end
  end
end
