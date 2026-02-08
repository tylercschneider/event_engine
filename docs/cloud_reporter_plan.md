# EventEngine Cloud Reporter — Gem-Side Plan

## Overview

Add an optional Cloud Reporter module to the EventEngine gem. When a customer configures an API key, the gem begins sending lightweight event metadata to the EventEngine Cloud SaaS. No business data (payloads) ever leaves their infrastructure.

The reporter is **zero-impact when unconfigured** — no new dependencies, no behavior changes, no network calls.

---

## Phase 1: Configuration

### Add cloud config options to `EventEngine::Configuration`

```ruby
attr_accessor :cloud_api_key        # String, nil by default
attr_accessor :cloud_endpoint       # String, default: "https://api.eventengine.dev/v1/ingest"
attr_accessor :cloud_environment    # String, default: Rails.env
attr_accessor :cloud_app_name       # String, default: Rails.application.class.module_parent_name
attr_accessor :cloud_enabled        # Boolean, default: -> { cloud_api_key.present? }
attr_accessor :cloud_batch_size     # Integer, default: 50
attr_accessor :cloud_flush_interval # Integer (seconds), default: 10
```

**Customer-facing config:**

```ruby
EventEngine.configure do |config|
  config.cloud_api_key = ENV["EVENT_ENGINE_CLOUD_KEY"]
  # Everything else has sensible defaults
end
```

### Files to modify
- `lib/event_engine/configuration.rb` — add attributes and defaults

---

## Phase 2: Reporter Core

### `EventEngine::Cloud::Reporter`

Singleton responsible for collecting and batching event metadata, then flushing to the Cloud API on a timer or when batch is full.

```
lib/event_engine/cloud/
  reporter.rb        # Singleton, manages lifecycle
  batch.rb           # Thread-safe batch accumulator
  api_client.rb      # HTTP client for Cloud API
  serializer.rb      # Converts events/metrics to API payload
```

### Reporter Lifecycle

1. **Start** — Called during engine boot if `cloud_enabled`
2. **Collect** — Subscribes to ActiveSupport::Notifications (already instrumented)
3. **Batch** — Accumulates entries in a thread-safe array
4. **Flush** — Posts batch to Cloud API every `flush_interval` seconds or when `batch_size` reached
5. **Shutdown** — Flushes remaining entries on process exit (`at_exit` hook)

### What Gets Reported (metadata only)

Per-event entry:
```json
{
  "event_id": 12345,
  "event_name": "order.placed",
  "event_type": "domain",
  "event_version": 2,
  "idempotency_key": "uuid",
  "status": "published",
  "attempts": 1,
  "occurred_at": "2026-01-15T10:30:00Z",
  "published_at": "2026-01-15T10:30:01Z",
  "dead_lettered_at": null,
  "latency_ms": 1000,
  "timestamp": "2026-01-15T10:30:01Z"
}
```

Periodic heartbeat (every flush):
```json
{
  "type": "heartbeat",
  "app_name": "MyApp",
  "environment": "production",
  "gem_version": "0.1.0",
  "ruby_version": "3.2.0",
  "rails_version": "7.1.6",
  "schema_fingerprints": {
    "order.placed": "sha256...",
    "payment.processed": "sha256..."
  },
  "uptime_seconds": 3600
}
```

**What is NEVER sent:**
- `payload` field (business data)
- `metadata` field (could contain PII)
- Database connection strings or credentials
- Any request/user context

---

## Phase 3: Notification Subscribers

The gem already instruments these events via `ActiveSupport::Notifications`:

| Notification | Data Available | Where |
|---|---|---|
| `event_engine.event_emitted` | event_name, event_version, event_id, idempotency_key | EventEmitter |
| `event_engine.event_published` | event_name, event_version, event_id | OutboxPublisher |
| `event_engine.event_dead_lettered` | event_name, event_version, event_id, attempts, error_message, error_class | OutboxPublisher |
| `event_engine.publish_batch` | count | OutboxPublisher |

### New subscribers to add

```ruby
# lib/event_engine/cloud/subscribers.rb
module EventEngine
  module Cloud
    class Subscribers
      def self.subscribe!
        ActiveSupport::Notifications.subscribe("event_engine.event_emitted") do |*, payload|
          Reporter.instance.track_emit(payload)
        end

        ActiveSupport::Notifications.subscribe("event_engine.event_published") do |*, payload|
          Reporter.instance.track_publish(payload)
        end

        ActiveSupport::Notifications.subscribe("event_engine.event_dead_lettered") do |*, payload|
          Reporter.instance.track_dead_letter(payload)
        end
      end
    end
  end
end
```

### Files to create
- `lib/event_engine/cloud/subscribers.rb`

---

## Phase 4: HTTP Client

### `EventEngine::Cloud::ApiClient`

Minimal HTTP client using `Net::HTTP` (no new gem dependencies).

```ruby
# lib/event_engine/cloud/api_client.rb
module EventEngine
  module Cloud
    class ApiClient
      TIMEOUT = 5 # seconds

      def initialize(api_key:, endpoint:)
        @api_key = api_key
        @endpoint = endpoint
      end

      def send_batch(entries)
        uri = URI("#{@endpoint}/events")
        # POST with JSON body
        # Headers: Authorization: Bearer <api_key>
        #          Content-Type: application/json
        #          X-EventEngine-Gem-Version: EventEngine::VERSION
        # Body: { "entries": [...] }
        # Fire-and-forget: log errors but never raise
      end

      def send_heartbeat(heartbeat)
        uri = URI("#{@endpoint}/heartbeat")
        # Same pattern
      end
    end
  end
end
```

**Key design decisions:**
- Uses `Net::HTTP` — zero new dependencies
- 5-second timeout — never blocks the app
- All errors are rescued and logged — reporter failure must never affect the app
- Runs on a background thread — flush is non-blocking

---

## Phase 5: Engine Boot Integration

### Modify `lib/event_engine/engine.rb`

After schema loading succeeds, conditionally start the reporter:

```ruby
initializer "event_engine.cloud_reporter" do |app|
  app.config.after_initialize do
    if EventEngine.configuration.cloud_enabled
      EventEngine::Cloud::Subscribers.subscribe!
      EventEngine::Cloud::Reporter.instance.start
    end
  end
end
```

### Shutdown hook

```ruby
at_exit do
  EventEngine::Cloud::Reporter.instance.shutdown if EventEngine.configuration.cloud_enabled
end
```

---

## Phase 6: Secure Payload Fetch Endpoint (Optional, Later)

For the "inspect event detail" feature in the Cloud dashboard, the SaaS needs to fetch a specific event's payload on-demand from the customer's app. This keeps payload data out of the SaaS database.

### New route and controller

```ruby
# config/routes.rb (addition)
namespace :cloud_api do
  resources :events, only: [:show]
end
```

```ruby
# app/controllers/event_engine/cloud_api/events_controller.rb
module EventEngine
  module CloudApi
    class EventsController < ActionController::API
      before_action :authenticate_cloud!

      def show
        event = OutboxEvent.find(params[:id])
        render json: {
          id: event.id,
          event_name: event.event_name,
          payload: event.payload,
          metadata: event.metadata
        }
      end

      private

      def authenticate_cloud!
        token = request.headers["Authorization"]&.delete_prefix("Bearer ")
        head :unauthorized unless token == EventEngine.configuration.cloud_api_key
      end
    end
  end
end
```

**Security:** The request originates from the user's browser via the SaaS dashboard (CORS or proxy), authenticated with the same API key. Payload is fetched, displayed, but never stored on the SaaS side.

This phase is optional and can be deferred until after the core reporter is working.

---

## File Summary

### New files
```
lib/event_engine/cloud/
  reporter.rb
  batch.rb
  api_client.rb
  serializer.rb
  subscribers.rb

# Phase 6 (later)
app/controllers/event_engine/cloud_api/events_controller.rb
```

### Modified files
```
lib/event_engine/configuration.rb   — add cloud_* attributes
lib/event_engine/engine.rb          — start reporter on boot
config/routes.rb                    — add cloud_api routes (Phase 6)
```

### New test files
```
test/lib/event_engine/cloud/reporter_test.rb
test/lib/event_engine/cloud/batch_test.rb
test/lib/event_engine/cloud/api_client_test.rb
test/lib/event_engine/cloud/serializer_test.rb
test/lib/event_engine/cloud/subscribers_test.rb
test/controllers/event_engine/cloud_api/events_controller_test.rb
```

---

## Build Order (TDD)

Following the project's TDD cycle:

1. **Configuration** — Test that cloud config attributes exist with correct defaults, that `cloud_enabled` is false when no key set
2. **Serializer** — Test that events are serialized to the expected metadata format, payloads are excluded
3. **Batch** — Test thread-safe accumulation, size limits, drain
4. **ApiClient** — Test HTTP calls with WebMock/stub, error handling, timeout behavior
5. **Subscribers** — Test that AS::Notifications trigger reporter methods
6. **Reporter** — Integration: test start/collect/flush/shutdown lifecycle
7. **Engine boot** — Test reporter starts only when cloud_api_key is present
8. **Payload endpoint** — Test auth, response format, 404 handling

Each step: write failing test, make it pass, commit, refactor, commit.

---

## Dependencies

**None added.** The reporter uses only:
- `Net::HTTP` (stdlib)
- `JSON` (stdlib)
- `ActiveSupport::Notifications` (already used)
- `Thread` / `Mutex` (stdlib)

This is critical — adding a gem dependency to EventEngine would create friction for adoption.

---

## Failure Isolation

The reporter MUST be invisible to the host application:

- All network calls are rescued — errors are logged, never raised
- Background thread — never blocks request cycle
- Graceful degradation — if the Cloud API is down, entries are dropped (not queued forever)
- Memory bounded — batch has a max size, oldest entries dropped if flush fails repeatedly
- No monkey-patching — uses only AS::Notifications subscription

If the reporter breaks, the only symptom should be missing data in the Cloud dashboard, never an error in the customer's app.
