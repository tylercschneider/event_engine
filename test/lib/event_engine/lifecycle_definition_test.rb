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

    test "every generated event carries the declared process_type" do
      definition = Class.new(EventEngine::LifecycleDefinition) do
        subject :export_csv
        event_type :product
        process_type :broker
        lifecycle :started, :completed, :failed
      end

      process_types = definition.generated_events.map { |event| event.schema.process_type }

      assert_equal [:broker, :broker, :broker], process_types
    end

    test "shared required inputs appear on every generated event" do
      definition = Class.new(EventEngine::LifecycleDefinition) do
        subject :export_csv
        event_type :product
        input :export
        lifecycle :started, :completed, :failed
      end

      required_inputs = definition.generated_events.map { |event| event.schema.required_inputs }

      assert_equal [[:export], [:export], [:export]], required_inputs
    end

    test "shared payload fields appear on every generated event" do
      definition = Class.new(EventEngine::LifecycleDefinition) do
        subject :export_csv
        event_type :product
        input :export
        required_payload :format, from: :export, attr: :format
        lifecycle :started, :completed, :failed
      end

      payload_fields = definition.generated_events.map { |event| event.schema.payload_fields }

      assert_equal [[{ name: :format, required: true, from: :export, attr: :format }]] * 3, payload_fields
    end
  end
end
