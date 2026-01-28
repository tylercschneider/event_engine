# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2025-06-02

### Added

- Event definition DSL (`event_name`, `event_type`, `input`, `required_payload`, `optional_payload`)
- Schema compilation via `DslCompiler` and `EventSchemaDumper`
- Schema versioning with SHA256 fingerprint-based version detection
- Schema drift detection via `SchemaDriftGuard` and rake tasks
- `SchemaRegistry` for in-memory schema lookup at runtime
- Outbox pattern: `OutboxWriter`, `OutboxPublisher` with configurable batch size and max attempts
- Dead letter support for failed publish attempts
- `EventEmitter` and `EventBuilder` for event construction
- Dynamic helper method installation (`EventEngine.cow_fed(...)`)
- Pluggable transport interface with `InMemoryTransport` and `Kafka` adapters
- `DefinitionLoader` for auto-loading event definitions
- Inline and ActiveJob delivery adapters
- `occurred_at` and `metadata` support on outbox events
- Rails engine generator for installation
- Rake tasks: `event_engine:schema`, `event_engine:schema:dump`

[Unreleased]: https://github.com/tylercschneider/event_engine/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/tylercschneider/event_engine/releases/tag/v0.1.0
