# EventEngine - Changes for Website + Interactive Demo Launch

Goal: Publish gem, build a promotional website with interactive demo, use it to establish credibility and attract Rails consulting work.

## Critical (must do before website launch)

### 1. Fix gem publishing blocker (5 min)
- Uncomment `allowed_push_host` in gemspec
- Set to `https://rubygems.org`

### 2. Fix rake task naming inconsistency (2 hours)
- Engine error message references `event_engine:schema:dump`
- Verify actual task name matches
- Update all references: engine.rb, README.md, CLAUDE.md, START_SESSION.md

### 3. Dashboard auth default - deny by default (2 hours)
- Current: `dashboard_auth` defaults to nil = open access
- Fix: Default to deny. Require explicit configuration.
- Add clear error message when dashboard_auth not configured

### 4. Basic YARD docs on public API (8-10 hours)
- `EventEngine` module (boot_from_schema!, configure, install_helpers)
- `EventDefinition` and DSL methods
- `Configuration` class
- `SchemaRegistry` public interface
- `Transport` interface contract
- Include `@example` blocks for key entry points

### 5. Gemspec metadata (30 min)
- Add `bug_tracker_uri`
- Add `documentation_uri`
- Verify homepage URL is correct

## Important (do for credibility)

### 6. Dashboard CSS styling (6-8 hours)
- Currently unstyled HTML tables
- Add clean, minimal CSS (Tailwind or simple custom)
- Style: event list, dead letter queue, event detail with JSON viewer
- This is what people will SEE on the website demo

### 7. CONTRIBUTING.md (1 hour)
- Dev setup instructions
- Testing guidelines
- PR process
- Code style expectations

### 8. Fix CHANGELOG date (15 min)
- v0.1.0 date says 2025-06-02, verify against actual git history

### 9. Configuration safety (2 hours)
- Validate transport is set when using :active_job adapter
- Run validation at boot, not just when `validate!` is called
- Add NullTransport that logs warnings

## Nice to have (after launch)

### 10. Migration generator (3 hours)
- Or clearly document that `rails event_engine:install:migrations` works

### 11. Definition loading docs (1.5 hours)
- Clarify: put definitions in `app/event_definitions/`
- Document Rails initialization order
- Add warning if no definitions found at boot

### 12. Kafka integration tests (8 hours)
- Docker compose with real Kafka broker
- Integration test that publishes and consumes
- Currently mocked only - fine for v0.1.0 but note the limitation

## For the Website / Interactive Demo

### What to show
- **Live event definition** - show the DSL, explain what each line does
- **Event emission** - trigger an event, watch it appear in outbox
- **Dashboard** - show the monitoring UI (this is why styling matters)
- **Dead letter recovery** - show what happens when delivery fails
- **Schema drift detection** - show the safety guard

### Website structure suggestion
- Hero: "Schema-first event pipeline for Rails"
- Problem: "Events are critical infrastructure. Don't build it from scratch."
- How it works: 3-step visual (Define → Emit → Deliver)
- Interactive demo: Embedded or video walkthrough of dashboard
- Install: `gem 'event_engine'` + quick start
- GitHub link + RubyGems badge
- "Built by [you]" - link to your consulting/services page

### Promotion plan
- Write a blog post: "Why I built a schema-first event pipeline for Rails"
- Post to: GoRails community, Ruby Weekly newsletter, r/rails, r/ruby
- Share on X/Twitter with demo GIF
- Submit to Ruby Toolbox
- Cross-post to dev.to and Hashnode

## Priority order for execution

1. Fix publishing blockers (#1, #2, #3) - 4 hours
2. Dashboard styling (#6) - 8 hours (this IS the demo)
3. YARD docs (#4) - 10 hours
4. Gem metadata + CHANGELOG + CONTRIBUTING (#5, #7, #8) - 2 hours
5. Publish to RubyGems
6. Build website
7. Write blog post
8. Promote

**Total to launch-ready: ~24 hours of focused work**
