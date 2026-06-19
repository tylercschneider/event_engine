require "test_helper"
require "event_engine/schema_diff"

class EventEngineSchemaDiffTest < ActiveSupport::TestCase
  test "reports no change when expected and actual match" do
    diff = EventEngine::SchemaDiff.new(expected: "a\n", actual: "a\n")

    assert_not diff.changed?
  end

  test "reports a change when expected and actual differ" do
    diff = EventEngine::SchemaDiff.new(expected: "a\n", actual: "b\n")

    assert diff.changed?
  end

  test "renders an added line prefixed with a plus" do
    diff = EventEngine::SchemaDiff.new(expected: "a\n", actual: "a\nb\n")

    assert_includes diff.to_s, "+b"
  end

  test "renders a removed line prefixed with a minus" do
    diff = EventEngine::SchemaDiff.new(expected: "a\nb\n", actual: "a\n")

    assert_includes diff.to_s, "-b"
  end
end
