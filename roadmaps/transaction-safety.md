# Transaction Safety for Inline Delivery

## Problem

When using `:inline` delivery adapter, `OutboxPublisher` runs immediately after `OutboxWriter.write`. If the emit call happens inside a transaction (e.g., from an `after_create` callback), publishing occurs before the transaction commits.

**Current flow with `:inline`:**
```ruby
Goal.transaction do
  goal.save!
  EventEngine.goal_created(goal: goal)
    # 1. OutboxEvent.create! ← inside transaction
    # 2. OutboxPublisher.call ← runs NOW, inside transaction
    #    - Publishes to Kafka
    #    - Marks event as published
end
# 3. Transaction commits
```

**Risk:** If something after publishing but before commit fails, the transaction rolls back but the event was already sent to Kafka. Kafka now has an event for a Goal that doesn't exist.

## Current Workaround

Use `:active_job` delivery adapter:
```ruby
EventEngine.configure do |c|
  c.delivery_adapter = :active_job
end
```

With `:active_job`, publishing is deferred to a background job that runs after the request completes (and thus after the transaction commits).

## Proposed Solution

Make `:inline` mode transaction-aware by deferring publishing until after commit when inside a transaction.

### Option A: Use `after_commit` Hook

```ruby
# lib/event_engine/delivery.rb
module Delivery
  def self.enqueue(&block)
    adapter = EventEngine.configuration.delivery_adapter || :inline

    case adapter
    when :inline
      if ActiveRecord::Base.connection.transaction_open?
        # Defer to after commit
        ActiveRecord::Base.connection.after_commit { yield if block_given? }
      else
        yield if block_given?
      end
    when :active_job
      PublishOutboxEventsJob.perform_later
    else
      raise ArgumentError, "Unknown delivery adapter: #{adapter}"
    end
  end
end
```

**Pros:**
- Simple change
- Preserves immediate publishing when no transaction

**Cons:**
- Relies on Rails' `after_commit` callback
- Multiple events in same transaction all defer separately

### Option B: Batch After Commit

Collect event IDs during transaction, publish all in one batch after commit.

```ruby
# lib/event_engine/transaction_buffer.rb
module TransactionBuffer
  def self.buffer(event_id)
    if ActiveRecord::Base.connection.transaction_open?
      pending_events << event_id
      ensure_after_commit_registered
    else
      yield
    end
  end

  def self.pending_events
    Thread.current[:event_engine_pending] ||= []
  end

  def self.ensure_after_commit_registered
    return if Thread.current[:event_engine_after_commit_registered]
    Thread.current[:event_engine_after_commit_registered] = true

    ActiveRecord::Base.connection.after_commit do
      publish_pending_events
      Thread.current[:event_engine_pending] = []
      Thread.current[:event_engine_after_commit_registered] = false
    end
  end

  def self.publish_pending_events
    # Publish all buffered events in one batch
  end
end
```

**Pros:**
- More efficient (single publish call for multiple events)
- Cleaner semantics

**Cons:**
- More complex
- Thread-local state management

### Option C: New Adapter `:inline_safe`

Add a new adapter that explicitly handles transactions, keeping `:inline` behavior unchanged for backwards compatibility.

```ruby
case adapter
when :inline
  yield if block_given?
when :inline_safe
  # Transaction-aware version
when :active_job
  PublishOutboxEventsJob.perform_later
end
```

**Pros:**
- No breaking changes
- Explicit opt-in

**Cons:**
- More options to explain
- Users might not know which to choose

## Recommendation

Start with **Option A** (simple `after_commit` hook) as the default behavior for `:inline`. This:
1. Fixes the transaction safety issue
2. Requires minimal code change
3. Is the expected behavior for most users

If performance becomes an issue (many events in one transaction), upgrade to Option B.

## Test Cases

```ruby
test "inline delivery defers publishing when inside transaction" do
  published = false
  transport = MockTransport.new { published = true }
  EventEngine.configure { |c| c.transport = transport }

  Goal.transaction do
    EventEngine.goal_created(goal: build(:goal))
    assert_not published, "Should not publish inside transaction"
  end

  assert published, "Should publish after commit"
end

test "inline delivery publishes immediately when no transaction" do
  published = false
  transport = MockTransport.new { published = true }
  EventEngine.configure { |c| c.transport = transport }

  EventEngine.goal_created(goal: build(:goal))
  assert published, "Should publish immediately"
end

test "inline delivery does not publish on rollback" do
  published = false
  transport = MockTransport.new { published = true }
  EventEngine.configure { |c| c.transport = transport }

  begin
    Goal.transaction do
      EventEngine.goal_created(goal: build(:goal))
      raise ActiveRecord::Rollback
    end
  rescue
  end

  assert_not published, "Should not publish on rollback"
end
```

## Implementation Steps

1. [ ] Add transaction detection to `Delivery.enqueue`
2. [ ] Use `after_commit` to defer inline publishing
3. [ ] Add tests for transaction scenarios
4. [ ] Update README with transaction safety notes
5. [ ] Consider adding `:inline_safe` as explicit option (optional)
