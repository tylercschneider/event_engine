# EventEngine Cloud — SaaS Dashboard Plan

## Overview

A standalone web application that receives event metadata from EventEngine gem instances, stores it, and provides real-time observability, alerting, schema intelligence, and debugging tools. This is the paid product.

Customers install the gem (free), add one config line with an API key, and get production-grade event visibility within minutes.

---

## Tech Stack (Recommended)

| Layer | Choice | Why |
|---|---|---|
| Backend | Rails 7.2+ | Same ecosystem as gem users, fast to build |
| Frontend | Hotwire (Turbo + Stimulus) | Real-time updates without SPA complexity, ship fast |
| Charts | Chartkick + Chart.js | Works natively with Rails, good enough to start |
| Database | PostgreSQL | Time-range queries, JSONB, partitioning later |
| Background Jobs | Sidekiq | Reliable for ingestion workers and alerting |
| Auth | Devise or custom | Standard Rails auth |
| Billing | Stripe | Usage-based billing, metered subscriptions |
| Hosting | Heroku or Render to start | Fast deploy, scale later |
| WebSockets | ActionCable | Live event stream in dashboard |

**Note:** This stack prioritizes speed to market. You can swap pieces later (e.g., TimescaleDB for time-series, React for frontend) once you have paying customers validating the product.

---

## Data Model

### Core Tables

```ruby
# Organizations — a company/team account
create_table :organizations do |t|
  t.string :name, null: false
  t.string :slug, null: false, index: { unique: true }
  t.string :plan, default: "free"         # free, starter, pro, enterprise
  t.timestamps
end

# Users — people who log in
create_table :users do |t|
  t.references :organization, null: false
  t.string :email, null: false, index: { unique: true }
  t.string :role, default: "member"       # owner, admin, member
  # Devise fields...
  t.timestamps
end

# Apps — a customer's Rails app instance reporting to us
create_table :apps do |t|
  t.references :organization, null: false
  t.string :name, null: false              # "MyApp", "PaymentService"
  t.string :environment, null: false       # "production", "staging"
  t.string :api_key, null: false, index: { unique: true }
  t.string :gem_version                    # last reported gem version
  t.datetime :last_heartbeat_at
  t.timestamps
end

# EventEntries — the main table, one row per reported event
create_table :event_entries do |t|
  t.references :app, null: false
  t.bigint :remote_event_id                # event ID from customer's DB
  t.string :event_name, null: false
  t.string :event_type
  t.integer :event_version
  t.string :idempotency_key
  t.string :status, null: false            # emitted, published, dead_lettered
  t.integer :attempts, default: 0
  t.integer :latency_ms                    # time from emit to publish
  t.string :error_message                  # if dead_lettered
  t.string :error_class                    # if dead_lettered
  t.datetime :occurred_at
  t.datetime :published_at
  t.datetime :dead_lettered_at
  t.datetime :reported_at, null: false     # when we received it
  t.timestamps
end

add_index :event_entries, [:app_id, :event_name, :reported_at]
add_index :event_entries, [:app_id, :status, :reported_at]
add_index :event_entries, [:app_id, :reported_at]

# SchemaSnapshots — track schema changes over time
create_table :schema_snapshots do |t|
  t.references :app, null: false
  t.string :event_name, null: false
  t.string :fingerprint, null: false
  t.integer :event_version
  t.jsonb :schema_definition               # full schema struct as JSON
  t.datetime :first_seen_at
  t.timestamps
end

add_index :schema_snapshots, [:app_id, :event_name, :fingerprint], unique: true

# Alerts — configured alert rules
create_table :alerts do |t|
  t.references :organization, null: false
  t.string :name, null: false
  t.string :alert_type, null: false        # dead_letter_threshold, latency_spike,
                                           # throughput_drop, heartbeat_missing
  t.jsonb :conditions, default: {}         # { "threshold": 10, "window_minutes": 5 }
  t.string :channel, null: false           # slack, email, pagerduty, webhook
  t.jsonb :channel_config, default: {}     # { "webhook_url": "..." }
  t.boolean :enabled, default: true
  t.datetime :last_triggered_at
  t.timestamps
end

# AlertEvents — log of alert firings
create_table :alert_events do |t|
  t.references :alert, null: false
  t.references :app
  t.string :event_name                     # which event type triggered it
  t.jsonb :context, default: {}            # snapshot of data that triggered alert
  t.datetime :triggered_at, null: false
  t.timestamps
end
```

---

## API: Ingestion Endpoints

These are what the gem's Reporter posts to.

### `POST /v1/ingest/events`

Receives batched event metadata from the gem.

```
Headers:
  Authorization: Bearer <api_key>
  Content-Type: application/json
  X-EventEngine-Gem-Version: 0.1.0

Body:
{
  "entries": [
    {
      "event_id": 12345,
      "event_name": "order.placed",
      "event_type": "domain",
      "event_version": 2,
      "idempotency_key": "abc-123",
      "status": "published",
      "attempts": 1,
      "latency_ms": 450,
      "occurred_at": "2026-01-15T10:30:00Z",
      "published_at": "2026-01-15T10:30:00.450Z",
      "dead_lettered_at": null,
      "error_message": null,
      "error_class": null,
      "timestamp": "2026-01-15T10:30:01Z"
    }
  ]
}

Response: 202 Accepted
{ "received": 25 }
```

**Processing:** Ingestion is async — the endpoint validates the API key, enqueues a Sidekiq job to write entries, and returns immediately. This keeps latency low for the gem.

### `POST /v1/ingest/heartbeat`

Receives periodic app health and schema info.

```
Body:
{
  "app_name": "MyApp",
  "environment": "production",
  "gem_version": "0.1.0",
  "ruby_version": "3.2.0",
  "rails_version": "7.1.6",
  "schema_fingerprints": {
    "order.placed": "sha256abc...",
    "payment.processed": "sha256def..."
  },
  "uptime_seconds": 7200
}

Response: 200 OK
```

**Processing:** Updates `apps.last_heartbeat_at` and `apps.gem_version`. Diffs schema fingerprints against stored snapshots — if a new fingerprint is seen, creates a new `SchemaSnapshot` row.

---

## Dashboard Pages

### 1. Overview (`/dashboard`)

The landing page after login. At-a-glance health of all apps.

**Content:**
- List of apps with status indicators (green = healthy, yellow = lagging, red = heartbeat missing)
- Sparkline charts: events/min over last hour per app
- Summary cards: total events today, dead letters today, avg latency
- Recent alerts (last 5)

### 2. App Detail (`/dashboard/apps/:id`)

Deep dive into a single app's event pipeline.

**Content:**
- **Throughput chart** — events per minute, last 1h / 6h / 24h / 7d toggle
- **Latency chart** — p50, p95, p99 publish latency over time
- **Error rate chart** — dead letters per minute over time
- **Event type breakdown** — table of event names with counts, avg latency, error rate
- **Status counts** — published / pending / dead-lettered (current)
- **Last heartbeat** — timestamp + gem version

### 3. Event Explorer (`/dashboard/apps/:id/events`)

Searchable, filterable list of individual events.

**Content:**
- Filter bar: event name, status, date range, version
- Sortable table: event_name, status, version, attempts, latency, occurred_at
- Click to expand: shows metadata we have (no payload — see below)
- **"View Payload" button** — fetches payload on-demand from customer's app via the Cloud API endpoint in the gem (Phase 6 of gem plan). Displayed in modal, never stored.

### 4. Dead Letters (`/dashboard/apps/:id/dead-letters`)

Focused view on failed events.

**Content:**
- Table: event_name, error_message, error_class, attempts, dead_lettered_at
- Group by error — "15 events failed with TimeoutError"
- **Retry action** — sends a command back to the customer's app (Phase 6 dependency)
- Trend chart — dead letters over time, overlay with deploys if available

### 5. Schema Catalog (`/dashboard/schemas`)

Cross-app directory of all event types.

**Content:**
- List of all event names across all apps
- Per event: versions, current schema definition, which apps emit it
- **Version history** — visual diff between schema versions
- **Compatibility notes** — fields added/removed between versions
- Source: populated from heartbeat `schema_fingerprints` + `SchemaSnapshot` table

### 6. Alerts (`/dashboard/alerts`)

Configure and review alert rules.

**Content:**
- List of configured alerts with status (enabled/disabled), last triggered
- Create/edit alert form:
  - Type: dead letter threshold, latency spike, throughput drop, heartbeat missing
  - Conditions: threshold value, time window
  - Channel: Slack webhook, email, PagerDuty, generic webhook
- Alert history log — when each alert fired and what triggered it

### 7. Settings (`/dashboard/settings`)

Organization and app management.

**Content:**
- Organization name, billing plan
- Team members — invite, remove, change roles
- Apps — list registered apps, regenerate API keys, delete
- Billing — current plan, usage, upgrade

---

## Alerting Engine

### Background job: `AlertEvaluatorJob`

Runs every minute via Sidekiq cron (sidekiq-cron or similar).

**Alert types:**

| Type | Logic |
|---|---|
| `dead_letter_threshold` | Count dead letters in last N minutes > threshold |
| `latency_spike` | p95 latency in last N minutes > threshold_ms |
| `throughput_drop` | Events/min dropped > X% compared to same window yesterday |
| `heartbeat_missing` | No heartbeat from app in last N minutes |

**Delivery:** Each alert has a channel config. On trigger:
1. Create `AlertEvent` row
2. Dispatch notification (Slack webhook, email via ActionMailer, PagerDuty API, generic webhook POST)
3. Rate-limit: don't re-fire same alert within cooldown period (e.g., 15 min)

---

## Auth & Multi-Tenancy

- **Organization-scoped** — all queries scoped to current user's org
- Standard email/password auth to start (Devise)
- API key auth for ingestion endpoints (stateless, fast)
- Invite flow: owner invites members by email
- Roles: owner (billing + admin), admin (manage apps + alerts), member (view only)

---

## Billing & Pricing

### Suggested tiers

| Plan | Price | Limits |
|---|---|---|
| **Free** | $0/mo | 1 app, 10k events/mo, 24h retention, no alerts |
| **Starter** | $29/mo | 3 apps, 100k events/mo, 7d retention, email alerts |
| **Pro** | $99/mo | 10 apps, 1M events/mo, 30d retention, all alert channels |
| **Enterprise** | Custom | Unlimited apps, custom retention, SLA, SSO |

**Metered billing:** Track `event_entries` count per org per month. Stripe metered subscriptions handle usage reporting and invoicing.

**Usage tracking:** Sidekiq job runs daily, reports usage to Stripe, warns customers approaching limits.

---

## Build Order

### Sprint 1: Foundation (Week 1–2)
- [ ] Rails app scaffold, PostgreSQL, Devise auth
- [ ] Organization + User + App models
- [ ] API key generation for apps
- [ ] `POST /v1/ingest/events` endpoint (validate key, write entries)
- [ ] `POST /v1/ingest/heartbeat` endpoint
- [ ] Sidekiq for async ingestion processing
- [ ] Basic overview dashboard (event counts, app list)

### Sprint 2: Core Dashboard (Week 3–4)
- [ ] App detail page with throughput chart (Chartkick)
- [ ] Event explorer with filtering and pagination
- [ ] Dead letters page with error grouping
- [ ] Latency chart (compute from emitted → published timestamps)
- [ ] Live updates via ActionCable (new events appear without refresh)

### Sprint 3: Schema Intelligence (Week 5–6)
- [ ] SchemaSnapshot model and heartbeat diffing
- [ ] Schema catalog page — list all events, their schemas, versions
- [ ] Version history with visual diff between versions
- [ ] "Which apps emit this event?" cross-reference

### Sprint 4: Alerting (Week 7–8)
- [ ] Alert model and CRUD UI
- [ ] AlertEvaluatorJob (runs every minute)
- [ ] Slack webhook integration
- [ ] Email alert delivery
- [ ] Alert history page
- [ ] Cooldown / rate-limiting logic

### Sprint 5: Billing & Polish (Week 9–10)
- [ ] Stripe integration (plans, subscriptions)
- [ ] Usage tracking and limit enforcement
- [ ] Invite flow for team members
- [ ] Settings pages (org, apps, billing)
- [ ] Onboarding flow (signup → create app → get API key → see first events)

### Sprint 6: Advanced Features (Week 11+)
- [ ] On-demand payload fetch (requires gem Phase 6)
- [ ] Event replay / retry from dashboard
- [ ] PagerDuty + generic webhook alert channels
- [ ] Multi-environment comparison (staging vs production)
- [ ] API for programmatic access to event data

---

## Onboarding Flow (Critical for Conversion)

This is the moment that turns a free gem user into a paying customer. It must be frictionless.

```
1. User clicks "Try EventEngine Cloud" on promo site
2. Sign up (email + password, or GitHub OAuth)
3. Create organization (name)
4. Register first app (name + environment → generates API key)
5. Page shows the one config line to add:

   EventEngine.configure do |config|
     config.cloud_api_key = "ee_live_abc123"
   end

6. Page polls for first heartbeat
7. "Waiting for first event..." with a spinner
8. First event arrives → celebration state → redirect to dashboard
```

This "waiting for first event" screen is the magic moment. When data appears within seconds of adding one line of config, the product sells itself.

---

## API Contract (Between Gem and SaaS)

### Authentication
- All requests include `Authorization: Bearer <api_key>`
- API key maps to exactly one `App` record
- Invalid key → 401
- Expired/disabled org → 403 with JSON error

### Versioning
- URL-prefixed: `/v1/ingest/...`
- Gem sends `X-EventEngine-Gem-Version` header
- SaaS can handle multiple gem versions simultaneously

### Error Responses
```json
{
  "error": "rate_limit_exceeded",
  "message": "Free plan limited to 10,000 events/month",
  "upgrade_url": "https://cloud.eventengine.dev/billing"
}
```

### Rate Limiting
- Per API key, enforced at ingestion
- Free: 100 requests/min
- Paid: 1,000 requests/min
- Returns 429 with `Retry-After` header
- Gem reporter should respect 429 and back off (built into gem-side ApiClient)

---

## Infrastructure Notes

### Start Simple
- Heroku or Render: 1 web dyno, 1 worker dyno, Heroku Postgres
- This handles the first 10–50 customers easily
- Total cost: ~$50–100/month

### Scale When Needed
- Move ingestion to a separate service if write volume gets high
- Partition `event_entries` by month (Postgres native partitioning)
- Add read replicas for dashboard queries
- Consider TimescaleDB if time-series queries become the bottleneck
- Redis caching for dashboard stats (1-min TTL)

### Data Retention
- Free plan: auto-delete entries older than 24h
- Paid plans: per-plan retention
- `RetentionCleanupJob` runs nightly, deletes expired entries
- Keep aggregated stats (hourly rollups) forever for trend charts

---

## Key Metrics to Track (for your own business)

- Signups per week
- Time from signup to first event received
- Free → paid conversion rate
- Monthly event volume per customer
- Churn rate by plan tier
- Most-used dashboard pages (informs what to build next)
