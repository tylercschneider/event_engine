# LEAKY TEST w/ discover! gross workaround

require "test_helper"

class EventRegistryDiscoverTest < ActiveSupport::TestCase
  setup do
    EventEngine::EventRegistry.reset!
  end

  test "discover! registers EventDefinition descendants and exposes current_schema" do
    cow_fed = Class.new(EventEngine::EventDefinition) do
      event_name "cow.fed"
      event_type "domain"
      input :cow
      required_payload :cow_id, from: :cow, attr: :id
    end

    pig_fed = Class.new(EventEngine::EventDefinition) do
      event_name "pig.fed"
      event_type "domain"
      input :pig
      required_payload :pig_id, from: :pig, attr: :id
    end

    EventEngine::EventRegistry.discover!(definitions: [cow_fed, pig_fed])

    cow_schema = EventEngine::EventRegistry.current_schema("cow.fed")

    assert_equal "cow.fed", cow_schema.event_name
    assert_equal "domain", cow_schema.event_type
    assert_equal 1, cow_schema.event_version

  end
end
