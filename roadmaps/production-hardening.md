# Production Hardening Plan

Status: **In Progress**

## Context

EventEngine is preparing for its first RubyGems release. The core event pipeline works (DSL → schema → outbox → transport), but an audit revealed critical gaps for production use. This plan addresses all of them across multiple PRs.

## Features

### 1. DB Constraints & Indexes
**Status:** Planned
**PR:** 1

- Add `NOT NULL` constraint on `event_name` at DB level (already enforced at model level)
- Add index on `created_at` (used by `ordered` scope)

### 2. Event Immutability
**Status:** Planned
**PR:** 1

- Add `attr_readonly` for core identity fields (`event_name`, `event_type`, `event_version`, `payload`, `metadata`, `occurred_at`, `idempotency_key`)
- Mutable fields (`published_at`, `attempts`, `dead_lettered_at`) remain writable

### 3. Transport Interface Validation
**Status:** Planned
**PR:** 1

- Validate that configured transport responds to `#publish` during `validate!`
- Raise `InvalidConfigurationError` with clear message if not

### 4. Dashboard Auth Warning
**Status:** Planned
**PR:** 2

- Log a warning when `dashboard_auth` is nil explaining how to configure it
- Still return 403 as before

### 5. Dead Letter Error Context
**Status:** Planned
**PR:** 2

- Add `last_error_message` (text) and `last_error_class` (string) columns
- Persist error info on every publish failure (not just dead-letters)
- Clear error fields on `retry!`
- Show error info in dashboard views

### 6. Aggregate Tracking
**Status:** Planned
**PR:** 3

- Add `aggregate_type`, `aggregate_id` (string), `aggregate_version` (integer) columns
- All nullable — aggregate tracking is optional
- Caller-provided version (no auto-increment to avoid SELECT MAX latency)
- Convenience method `OutboxEvent.next_aggregate_version(type, id)`
- Thread through full pipeline: helpers → emitter → outbox writer → transports → cloud serializer
- Add `for_aggregate` scope and composite index

### 7. Publisher Row Locking
**Status:** Planned
**PR:** 4

- Add `LockingStrategy` with adapter detection
- `PostgresStrategy` applies `FOR UPDATE SKIP LOCKED`
- `NullStrategy` for SQLite/dev (no-op)
- Wrap publisher batch in transaction
- Optional `configuration.locking_strategy` override

## PR Plan

| PR | Scope | ~Files | Status |
|---|---|---|---|
| 1 | DB constraints + event immutability + transport validation | 6 | Planned |
| 2 | Dead letter error context + dashboard auth warning | 8 | Planned |
| 3 | Aggregate tracking columns + pipeline | 10 | Planned |
| 4 | Publisher row locking | 5 | Planned |
