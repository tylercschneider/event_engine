# EventEngine Roadmap

This roadmap tracks the work needed to bring EventEngine from v0.1.0 to a production-grade, portfolio-ready gem.

Tracked as [GitHub Issues](https://github.com/tylercschneider/event_engine/issues) with the `roadmap` label.

---

## Phase 1 — Portfolio Hygiene

Quick wins that immediately improve how the project presents to reviewers.

- [x] **Complete gemspec metadata** — Fill in homepage, summary, description, allowed_push_host. Add changelog_uri and source_code_uri to metadata. ([#39](https://github.com/tylercschneider/event_engine/issues/39))
- [x] **Add GitHub Actions CI workflow** — Run `bundle exec rake test` on push/PR to main with Ruby matrix (3.2, 3.3). ([#40](https://github.com/tylercschneider/event_engine/issues/40))
- [x] **Add CHANGELOG.md** — Document v0.1.0 using Keep a Changelog format. ([#41](https://github.com/tylercschneider/event_engine/issues/41))

## Phase 2 — Core Improvements

Clean up existing code and finalize interfaces.

- [x] **Flesh out Kafka transport adapter** — Kept minimal (EventEngine does NOT manage Kafka). Added idempotency_key to published payload. Documented transport interface contract in README. ([#42](https://github.com/tylercschneider/event_engine/issues/42))
- [x] **Document idempotency_key intent and usage** — Auto-generated as UUID by default, with optional override. Passed to transports for consumer deduplication. Added README section. ([#43](https://github.com/tylercschneider/event_engine/issues/43))

## Phase 3 — New Capabilities

Features that make EventEngine genuinely usable in real projects.

- [x] **Add ActiveSupport::Notifications instrumentation** — Instrumented: `event_engine.event_emitted`, `event_engine.event_published`, `event_engine.event_dead_lettered`, `event_engine.publish_batch`. ([#44](https://github.com/tylercschneider/event_engine/issues/44))
- [ ] **Add lightweight event subscriber/callback system** — In-process hooks that fire after an event is written to the outbox (not a Kafka consumer). Support block-based and class-based registration. Stays within producer-side scope. ([#45](https://github.com/tylercschneider/event_engine/issues/45))
- [ ] **Add dead letter inspection and recovery tooling** — Scopes for querying dead letters, retry mechanism, rake tasks for manual recovery (`event_engine:dead_letters:list`, `event_engine:dead_letters:retry`). ([#46](https://github.com/tylercschneider/event_engine/issues/46))
- [ ] **Add outbox cleanup strategy** — Configurable retention period, rake task and optional ActiveJob for purging published events older than retention. Never delete unpublished or dead-lettered events. ([#47](https://github.com/tylercschneider/event_engine/issues/47))

## Phase 4 — Documentation

Polish after code stabilizes.

- [ ] **Add YARD docs to public API classes** — EventDefinition, Configuration, SchemaRegistry, transport interface, EventSchema, top-level EventEngine module. Include @example tags. Public API surface only. ([#48](https://github.com/tylercschneider/event_engine/issues/48))

## Phase 5 — Observability Dashboard

Capstone feature. Depends on instrumentation ([#44](https://github.com/tylercschneider/event_engine/issues/44)) and dead letter tooling ([#46](https://github.com/tylercschneider/event_engine/issues/46)).

- [ ] **Add basic observability dashboard** — Mountable Rails engine at `/event_engine/dashboard`. Shows outbox stats, event volume by name, dead letter queue with retry, recent events with payload inspection. Server-rendered HTML. Operational health view — heavier analytics live in the separate ingestion/dashboard repo. ([#49](https://github.com/tylercschneider/event_engine/issues/49))

---

## Related Projects

- **Event Analytics Dashboard** (separate repo) — Handles event ingestion from sources like ClickHouse, provides custom dashboards and widgets. Part of the same ecosystem but intentionally decoupled.
- **Demo App** (planned) — Standalone Rails app demonstrating data flow through the full EventEngine pipeline. Built after Phase 1-3 are complete.

## Design Principles

- **Producer-side only** — EventEngine handles event definition, schema management, and outbox persistence. Kafka setup and consumer implementation are the developer's responsibility.
- **Schema-first** — The compiled schema file is the source of truth at runtime. Definitions are development-time only.
- **Outbox pattern** — Events are durably persisted before transport. Writing and publishing are decoupled concerns.
- **Idempotency is downstream** — The idempotency_key is set on outbox events and passed through to transports. Enforcement is the consumer's responsibility.
