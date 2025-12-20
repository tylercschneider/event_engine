require "test_helper"

class EventEmitterGuardTest < ActiveSupport::TestCase
  test "raises when emitting before registry is loaded" do
    EventEngine::EventRegistry.reset!

    assert_raises(EventEngine::EventRegistry::RegistryFrozenError) do
      EventEngine::EventEmitter.emit(
        event_name: :cow_fed,
        data: {}
      )
    end
  end
end
