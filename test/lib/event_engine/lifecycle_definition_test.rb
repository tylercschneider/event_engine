require "test_helper"

module EventEngine
  class LifecycleDefinitionTest < ActiveSupport::TestCase
    test "lifecycle generates a snake_case event per verb" do
      definition = Class.new(EventEngine::LifecycleDefinition) do
        subject :export_csv
        event_type :product
        lifecycle :started, :completed, :failed
      end

      names = definition.generated_events.map { |event| event.schema.event_name }

      assert_equal [:export_csv_started, :export_csv_completed, :export_csv_failed], names
    end

    test "every generated event carries the declared subject" do
      definition = Class.new(EventEngine::LifecycleDefinition) do
        subject :export_csv
        event_type :product
        lifecycle :started, :completed, :failed
      end

      subjects = definition.generated_events.map { |event| event.schema.subject }

      assert_equal [:export_csv, :export_csv, :export_csv], subjects
    end
  end
end
