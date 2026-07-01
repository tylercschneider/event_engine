require "test_helper"

class DslCompilerReservedInputTest < ActiveSupport::TestCase
  test "compile rejects an input whose name collides with an envelope key" do
    definition = Class.new(EventEngine::EventDefinition) do
      event_name :cow_fed
      event_type :domain
      input :metadata
    end

    error = assert_raises(EventEngine::DslCompiler::ReservedInputNameError) do
      EventEngine::DslCompiler.compile([definition])
    end

    assert_includes error.message, "metadata"
  end
end
