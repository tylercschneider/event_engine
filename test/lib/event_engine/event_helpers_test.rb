require "test_helper"

module EventEngine
  class EventHelpersTest < ActiveSupport::TestCase
    class CowFed < EventDefinition
      event_name :cow_fed
      event_type :domain

      input :cow
      required_payload :weight, from: :cow, attr: :weight
    end

    setup do
      EventRegistry.reset!
      EventRegistry.register(CowFed)
      EventEngine.install_helpers(registry: EventRegistry)
    end

    test "defines helper method on EventEngine" do
      assert EventEngine.respond_to?(:cow_fed)
    end

    test "helper emits an OutboxEvent" do
      cow = OpenStruct.new(weight: 500)

      event = EventEngine.cow_fed(cow: cow)

      assert event.persisted?
      assert_equal "cow_fed", event.event_name
      assert_equal({ "weight" => 500 }, event.payload)
    end
  end
end
