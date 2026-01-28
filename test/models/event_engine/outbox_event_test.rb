require "test_helper"

module EventEngine
  class OutboxEventTest < ActiveSupport::TestCase
    # validations
    test "persists an outbox event" do
      event = OutboxEvent.create!(
        event_name: "example.event",
        event_type: "example.event",
        event_version: 1,
        occurred_at: Time.current,
        payload: {filler: "dummy"}
      )

      assert event.persisted?
    end

    test "outbox event is invalid without event_name" do
      event = OutboxEvent.new(event_type: "example.event", event_version: 1)

      assert_not event.valid?
    end

    test "outbox event is invalid without event_type" do
      event = OutboxEvent.new(event_name: "example.event", event_version: 1)

      assert_not event.valid?
    end

    test "outbox event is invalid without payload" do
      event = OutboxEvent.new(event_name: "example.event", event_type: "example.event", event_version: 1)

      assert_not event.valid?
    end

    test "duplicate idempotency_key is rejected" do
      OutboxEvent.create!(
        event_type: "OrderCreated",
        event_name: "order.created",
        event_version: 1,
        occurred_at: Time.current,
        payload: { filler: "a" },
        idempotency_key: "abc-123"
      )

      duplicate = OutboxEvent.new(
        event_type: "OrderCreated",
        event_name: "order.created",
        event_version: 1,
        occurred_at: Time.current,
        payload: { filler: "b" },
        idempotency_key: "abc-123"
      )

      assert_not duplicate.valid?
    end

    # lifecycle
    test "outbox event is unpublished by default" do
      event = OutboxEvent.create!(
        event_type: "example.event",
        event_name: "example.event",
        event_version: 1,
        occurred_at: Time.current,
        payload: {filler: "dummy"}
      )

      assert_nil event.published_at
    end

    test "mark_published! sets published_at" do
      event = OutboxEvent.create!(
        event_type: "example.event",
        event_name: "example.event",
        event_version: 1,
        occurred_at: Time.current,
        payload: {filler: "dummy"}
      )

      event.mark_published!

      assert_not_nil event.published_at
    end

    # idempotency
    test "duplicate idempotency_key raises at the database level" do
      OutboxEvent.create!(
        event_type: "OrderCreated",
        event_name: "order.created",
        event_version: 1,
        occurred_at: Time.current,
        payload: { filler: "a" },
        idempotency_key: "abc-123"
      )

      assert_raises ActiveRecord::RecordNotUnique do
        OutboxEvent.new(
          event_type: "OrderCreated",
          event_name: "order.created",
          event_version: 1,
          occurred_at: Time.current,
          payload: { filler: "b" },
          idempotency_key: "abc-123"
        ).save!(validate: false)
      end
    end

    # querying
    test "unpublished scope returns only unpublished events" do
      published = OutboxEvent.create!(
        event_type: "OrderCreated",
        event_name: "order.created",
        event_version: 1,
        occurred_at: Time.current,
        payload: { filler: "x" },
        published_at: Time.current
      )

      unpublished = OutboxEvent.create!(
        event_type: "OrderCreated",
        event_name: "order.created",
        event_version: 1,
        occurred_at: Time.current,
        payload: { filler: "y" }
      )

      assert_equal [unpublished], OutboxEvent.unpublished.to_a
    end

    test "unpublished events are ordered by created_at ascending" do
      older = OutboxEvent.create!(
        event_type: "OrderCreated",
        event_name: "order.created",
        event_version: 1,
        occurred_at: Time.current,
        payload: { filler: "a" }
      )

      travel 1.second

      newer = OutboxEvent.create!(
        event_type: "OrderCreated",
        event_name: "order.created",
        event_version: 1,
        occurred_at: Time.current,
        payload: { filler: "b" }
      )

      assert_equal [older, newer], OutboxEvent.unpublished.ordered.to_a
    end

    # dead letter recovery
    test "retry! resets attempts and clears dead_lettered_at" do
      event = OutboxEvent.create!(
        event_type: "OrderCreated",
        event_name: "order.created",
        event_version: 1,
        occurred_at: Time.current,
        payload: { filler: "a" },
        attempts: 5,
        dead_lettered_at: Time.current
      )

      assert event.dead_lettered?

      event.retry!

      assert_equal 0, event.attempts
      assert_nil event.dead_lettered_at
      assert_not event.dead_lettered?
    end
  end
end
