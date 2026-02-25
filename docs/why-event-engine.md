# Why Event Engine

## Why Implement an Event System

**The core problem: coupling.** As a Rails app grows, actions start triggering cascading side effects:

```ruby
# This starts innocent...
def create_order(params)
  order = Order.create!(params)
  OrderMailer.confirmation(order).deliver_later
  InventoryService.reserve(order)
  AnalyticsTracker.track("order_created", order)
  LoyaltyPoints.credit(order.user)
  WebhookService.notify(order)
  AuditLog.record(order)
end
```

Every new requirement means touching this method. A failure in any one call can break the whole flow. Testing requires stubbing everything. Deployment of the analytics service shouldn't require redeploying the orders service.

**With events, this becomes:**

```ruby
def create_order(params)
  order = Order.create!(params)
  EventEngine.order_created(order_id: order.id, user_id: order.user_id, total: order.total)
end
```

Each consumer handles its own concern independently. The producer doesn't know or care who's listening.

## When in the App Lifecycle

**Too early** — Day one of a greenfield app. You don't know your domain boundaries yet. You'd be guessing at event shapes and over-engineering.

**The sweet spot — when you start feeling these pains:**

- **Multiple models/services react to the same action** — the "fat callback" or "god service" smell (typically when you have 3+ side effects per action)
- **You're extracting your first microservice** — you need a reliable way for services to communicate without direct HTTP calls
- **Deployments cause cascading failures** — one service going down shouldn't break unrelated features
- **Testing is painful** — integration tests require the entire system because everything is directly coupled
- **Team boundaries are forming** — different teams own different parts of the system and step on each other

For most apps, this is roughly **year 1-2** or when you're past product-market fit and scaling the team/codebase.

**Too late** — You've already got a tangled web of service-to-service HTTP calls, shared databases, and no clear event contracts. You can still adopt it, but the migration cost is steep.

## What It Saves

**Engineering time** is the big one:

- **Building the plumbing yourself** — A production-grade outbox pattern with retry, dead-lettering, schema validation, and transport abstraction is easily **2-4 months** of senior engineer time to build and harden. EventEngine gives you that out of the box.

- **Debugging lost events** — Without the outbox pattern, teams commonly lose events when the message broker is temporarily unavailable. Each incident can cost **days** of investigation and manual data repair.

- **Cross-team coordination** — Without schema contracts, changing an event shape requires Slack threads, wiki pages, and hope. Schema drift detection catches breaking changes in CI automatically.

- **Onboarding** — A DSL-defined event catalog is self-documenting. New engineers can read `app/event_definitions/` and understand every event the system produces, rather than grepping through scattered publish calls.

**Concrete rough estimates for a mid-size Rails team (5-15 engineers):**

| Without EventEngine | Cost |
|---|---|
| Build your own outbox + publisher | 2-4 months eng time |
| Schema management / contract testing | 1-2 months eng time |
| Lost event incidents (per year) | 3-10 incidents, days each |
| Cross-team "what changed?" debugging | Ongoing drag on velocity |

| With EventEngine | Cost |
|---|---|
| Integration + learning | Days to a couple of weeks |
| Defining events via DSL | Hours per event |
| Ongoing maintenance | Minimal — CI catches drift |

**The real savings aren't just the build cost — it's the incidents you never have.** One production data inconsistency from a lost event can cost more in investigation, repair, and customer impact than the entire setup cost of a proper event system.

## The Short Version

An app wants events when the cost of coupling exceeds the cost of indirection. That tipping point usually arrives when you have multiple consumers of the same business action, are splitting into services, or are losing sleep over reliability. A gem like EventEngine lets you adopt the pattern without spending months building infrastructure that isn't your core product.
