require "test_helper"
require "rake"

class EventEngineSchemaVerifyTaskTest < ActiveSupport::TestCase
  setup do
    Rake.application = Rake::Application.new
    load EventEngine::Engine.root.join("lib/tasks/event_engine_schema.rake")
    Rake::Task.define_task(:environment)
  end

  test "defines the schema:verify task" do
    assert Rake::Task.task_defined?("event_engine:schema:verify")
  end
end
