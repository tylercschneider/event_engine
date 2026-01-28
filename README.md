# EventEngine

EventEngine is a Rails engine that provides a schema-first event pipeline with:
- **Event definitions** in Ruby DSL.
- **Schema generation** to a canonical `db/event_schema.rb`.
- **Outbox storage** with a background publisher.
- **Transport adapters** (in-memory or Kafka) for delivery.

This README is optimized for humans and automated assistants. It includes a
complete setup path, usage patterns, configuration, and known issues.

---

## Quick start (new Rails app)

1. **Add the gem** to your application:

   ```ruby
   # Gemfile
   gem "event_engine"
   ```

2. **Bundle install**:

   ```bash
   bundle install
   ```

3. **Run migrations** to create the outbox table:

   ```bash
   bin/rails db:migrate
   ```

4. **Define events** with the DSL (examples below).

5. **Generate the schema file**:

   ```bash
   bin/rails event_engine:schema:dump
   ```

6. **Commit `db/event_schema.rb`** (required in production).

7. **Configure the transport and delivery adapter** (see Configuration).

---

## Core concepts

### 1) Event Definitions → Schema
Event definitions describe:
- event name/type
- input objects
- payload fields and type casting

These definitions are compiled into a canonical schema file (`db/event_schema.rb`).
The schema file is authoritative in production.

### 2) Event Emission
At boot, EventEngine loads the schema file and installs helper methods for
each event. Example: if you define `event_name :cow_fed`, then
`EventEngine.cow_fed(...)` becomes available.

### 3) Outbox + Publisher
Events are written to `event_engine_outbox_events`. A publisher reads
unpublished events and sends them through the configured transport.

---

## Defining events

Create event definitions (typically in `app/events` or `app/event_definitions`).

```ruby
class CowFed < EventEngine::EventDefinition
  input :cow
  optional_input :farmer

  event_name :cow_fed
  event_type :domain

  entity_class :class_name, from: :cow, type: :string
  entity_id :id, from: :cow, type: :int
  entity_version :version, from: :cow, type: :int

  required_payload :weight, from: :cow, type: :float
  optional_payload :name, from: :farmer, type: :string
end
```

> Tip: ensure your definition classes are eager loaded in Rails.

---

## Generating the schema

Generate the schema after adding or modifying definitions:

```bash
bin/rails event_engine:schema:dump
```

This creates/updates `db/event_schema.rb`. Commit it to source control.

---

## Emitting events

Once the schema is loaded (boot time), helpers are installed:

```ruby
EventEngine.cow_fed(
  cow: cow,
  farmer: farmer,
  occurred_at: Time.current,
  metadata: { request_id: "abc123" }
)
```

You can optionally set:
- `event_version:` (to force a specific schema version)
- `occurred_at:`
- `metadata:`

---

## Configuration

Add an initializer such as `config/initializers/event_engine.rb`:

```ruby
EventEngine.configure do |config|
  config.delivery_adapter = :inline # or :active_job

  # For development/testing:
  config.transport = EventEngine::Transports::InMemoryTransport.new

  # For Kafka (example):
  # client = Kafka.new(seed_brokers: ["kafka://localhost:9092"])
  # producer = EventEngine::KafkaProducer.new(client: client)
  # config.transport = EventEngine::Transports::Kafka.new(producer: producer)

  config.batch_size = 100
  config.max_attempts = 5
end
```

### Delivery modes
- `:inline` (default): publish immediately after writing to outbox.
- `:active_job`: enqueue `EventEngine::PublishOutboxEventsJob`.

---

## Outbox publishing

If you use `:active_job`, ensure your background job infrastructure is running.
Publishing also requires `config.transport` to be set; otherwise the job will
raise an error.

---

## Transport interface

A transport is any object that responds to `publish(event)`. EventEngine ships
with two transports:

- `EventEngine::Transports::InMemoryTransport` — stores events in memory (dev/test)
- `EventEngine::Transports::Kafka` — publishes to Kafka via an injected producer

### Writing a custom transport

```ruby
class MyTransport
  def publish(event)
    # event is an EventEngine::OutboxEvent with these attributes:
    #   event.event_name      # e.g. "cow.fed"
    #   event.event_type      # e.g. "domain"
    #   event.event_version   # e.g. 1
    #   event.idempotency_key # unique key for deduplication (may be nil)
    #   event.payload         # Hash of event data
    #   event.metadata        # Hash of contextual data (request_id, etc.)
    #   event.occurred_at     # Time the event occurred

    # Publish to your messaging system here
    # Raise an exception on failure (will be retried up to max_attempts)
  end
end
```

Configure your transport in the initializer:

```ruby
EventEngine.configure do |config|
  config.transport = MyTransport.new
end
```

### Kafka transport

EventEngine does **not** manage Kafka — you bring your own client. The Kafka
transport wraps your producer:

```ruby
# Using the ruby-kafka gem as an example
kafka_client = Kafka.new(seed_brokers: ENV["KAFKA_BROKERS"])
producer = EventEngine::KafkaProducer.new(client: kafka_client)

EventEngine.configure do |config|
  config.transport = EventEngine::Transports::Kafka.new(producer: producer)
end
```

The Kafka transport publishes to topics named `events.{event_name}` with a JSON
payload containing all event attributes. Customize topic naming or partition
keys in your producer implementation.

---

## Idempotency

Every outbox event is assigned an `idempotency_key` — a UUID generated
automatically when the event is emitted. This key is stored in the outbox table
(with a unique constraint) and passed through to transports for downstream
consumers.

### How it works

1. **Auto-generated by default** — Every event gets a unique UUID:

   ```ruby
   event = EventEngine.cow_fed(cow: cow)
   event.idempotency_key # => "550e8400-e29b-41d4-a716-446655440000"
   ```

2. **Override when needed** — Provide your own key for domain-specific deduplication:

   ```ruby
   EventEngine.cow_fed(
     cow: cow,
     idempotency_key: "cow-#{cow.id}-fed-#{Date.current}"
   )
   ```

3. **Outbox enforces uniqueness** — Duplicate keys are rejected at the database
   level, preventing the same logical event from being written twice.

4. **Transports pass it downstream** — The key is included in the published
   payload so consumers can deduplicate on their end.

### Consumer responsibility

EventEngine stores and transmits the idempotency key, but does **not** enforce
idempotent processing. Consumers must implement their own deduplication logic
using the key (e.g., checking a processed-events table before handling).

### When to override the idempotency key

Override the auto-generated UUID when you need domain-specific deduplication:

- Prevent duplicate events for the same business operation (e.g., one feed event per cow per day)
- Ensure retries of user actions don't create duplicate events
- Correlate events across systems using a shared identifier

---

## Troubleshooting & common errors

### Missing schema in production
On boot, EventEngine expects `db/event_schema.rb`. If missing outside
development/test, it raises and tells you to run the schema dump task.

### Unknown event or version
If you emit an event name/version not present in the schema, it raises
`EventEngine::SchemaRegistry::UnknownEventError`.

### Transport not configured
When using `:active_job`, the publisher raises if no transport is configured.

---

## Tasks / Issues to address

1. **Schema task naming mismatch**
   - Engine boot error message references `event_engine:schema_dump`
     but the schema writer header references `event_engine:schema:dump`.
   - Ensure the task is named consistently and update error text.

2. **README or docs for migrations**
   - There is no documented migration generator for the outbox table.
   - Consider adding a generator or documenting the required migration.

3. **Transport default safety**
   - Default `transport` is `nil`. If `delivery_adapter` is `:active_job`
     without transport set, the job raises. Consider a clearer failure path
     or default test transport in development.

4. **Definition loading clarity**
   - Ensure definition files are eager-loaded or documented for autoload paths.

---

## Contributing

1. Fork and create a feature branch.
2. Add tests for behavior changes.
3. Submit a PR.

---

## License
The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
