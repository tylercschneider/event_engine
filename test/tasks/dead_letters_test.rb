require "test_helper"
require "rake"

module EventEngine
  class DeadLettersTasksTest < ActiveSupport::TestCase
    setup do
      Rails.application.load_tasks
      Rake::Task.tasks.each(&:reenable)
    end

    test "dead_letters:list outputs dead-lettered events" do
      event = OutboxEvent.create!(
        event_name: "order.created",
        event_type: "domain",
        event_version: 1,
        payload: { order_id: 123 },
        occurred_at: Time.current,
        attempts: 5,
        dead_lettered_at: Time.current
      )

      output = capture_io do
        Rake::Task["event_engine:dead_letters:list"].invoke
      end.first

      assert_match(/#{event.id}/, output)
      assert_match(/order\.created/, output)
      assert_match(/5/, output)
    end

    test "dead_letters:list shows message when no dead letters exist" do
      output = capture_io do
        Rake::Task["event_engine:dead_letters:list"].invoke
      end.first

      assert_match(/no dead-lettered events/i, output)
    end
  end
end
