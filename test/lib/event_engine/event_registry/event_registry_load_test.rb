require "test_helper"

class EventRegistryLoadTest < ActiveSupport::TestCase
  setup do
    EventEngine::EventRegistry.reset!
  end

  test "registry is not loaded by default" do
    refute EventEngine::EventRegistry.loaded?
  end

  test "load! marks registry as loaded" do
    EventEngine::EventRegistry.load!(definitions: [])
    assert EventEngine::EventRegistry.loaded?
  end

  test "cannot register new definitions after load" do
    klass = Class.new(EventEngine::EventDefinition) do
      event_name "cow.fed"
      event_type "domain"
    end

    EventEngine::EventRegistry.load!(definitions: [klass])

    assert_raises(EventEngine::EventRegistry::RegistryFrozenError) do
      EventEngine::EventRegistry.register(klass)
    end
  end
end
