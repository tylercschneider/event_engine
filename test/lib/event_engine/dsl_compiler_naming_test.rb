require "test_helper"

class DslCompilerNamingTest < ActiveSupport::TestCase
  test "compile rejects a non-snake_case event name" do
    definition = Class.new(EventEngine::EventDefinition) do
      event_name :CowFed
      event_type :domain
    end

    assert_raises(EventEngine::DslCompiler::InvalidEventNameError) do
      EventEngine::DslCompiler.compile([definition])
    end
  end
end
