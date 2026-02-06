# EventEngine Promo Site — Build Plan

> A complete implementation spec for building the EventEngine promotional site.
> Built with Rails + Jumpstart Pro + Tailwind. Designed so a developer can pick this up and execute without ambiguity.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Tech Stack & Setup](#2-tech-stack--setup)
3. [Information Architecture](#3-information-architecture)
4. [Database Schema](#4-database-schema)
5. [Landing Page — Section-by-Section Spec](#5-landing-page--section-by-section-spec)
6. [Interactive Demo — The Centerpiece](#6-interactive-demo--the-centerpiece)
7. [Routes & Controllers](#7-routes--controllers)
8. [Models](#8-models)
9. [Views & Components](#9-views--components)
10. [Real-Time Infrastructure](#10-real-time-infrastructure)
11. [EventEngine Integration](#11-eventengine-integration)
12. [Copy & Messaging](#12-copy--messaging)
13. [Design Direction](#13-design-direction)
14. [Deployment](#14-deployment)
15. [Build Order](#15-build-order)
16. [Out of Scope (v1)](#16-out-of-scope-v1)

---

## 1. Project Overview

### What We're Building

A promotional site for EventEngine that serves two purposes:

1. **Sales page** — Explains the value proposition, shows how it works, presents pricing for implementation services
2. **Interactive demo** — Visitors use a live instance of EventEngine in-browser. They define events, emit them, watch them flow through the outbox pipeline in real-time, and inspect the outbox/dead-letter state. This is the differentiator — not a mockup, but the actual gem running.

### Target Audience

- Rails developers evaluating event-driven architecture
- Engineering leads/CTOs looking for a reliable event pipeline
- Teams currently using ad-hoc event systems that are breaking down

### Success Metrics

- Visitor clicks "Try the Demo" and successfully emits an event
- Visitor sees the full pipeline lifecycle (emit → outbox → publish → deliver)
- Visitor fills out contact/inquiry form

---

## 2. Tech Stack & Setup

### Stack

| Layer | Choice | Notes |
|-------|--------|-------|
| Framework | Rails 7.2+ | Latest stable |
| Starter | Jumpstart Pro | Authentication, billing, admin, Tailwind pre-configured |
| CSS | Tailwind CSS | Comes with Jumpstart |
| JS | Stimulus + Turbo | Comes with Jumpstart; Turbo Streams for real-time |
| Real-time | ActionCable + Turbo Streams | Live event feed |
| Database | PostgreSQL | Production-grade; Jumpstart default |
| Event pipeline | `event_engine` gem | The product itself, integrated as a dependency |
| Background jobs | Solid Queue or Sidekiq | Jumpstart configurable; needed for ActiveJob delivery |
| Deployment | Hatchbox, Render, or Fly.io | Needs WebSocket support for ActionCable |

### Initial Setup

```bash
# 1. Create new Jumpstart app (from Jumpstart Pro repo)
rails new event_engine_promo \
  -m https://raw.githubusercontent.com/excid3/jumpstart-pro/master/template.rb \
  --database=postgresql

# 2. Add event_engine gem to Gemfile
# Point at the GitHub repo or local path during development
gem "event_engine", github: "tylercschneider/event_engine", branch: "main"

# 3. Install EventEngine
bin/rails event_engine:install:migrations
bin/rails db:migrate

# 4. Create the event definitions (see Section 11)
# 5. Generate schema
bin/rails event_engine:schema:dump
```

### Environment Variables

```
DATABASE_URL=postgres://...
REDIS_URL=redis://...          # ActionCable adapter
RAILS_ENV=production
SECRET_KEY_BASE=...
```

---

## 3. Information Architecture

### Site Map

```
/                           → Landing page (sales + demo CTA)
/demo                       → Interactive demo (main playground)
/demo/events                → API: list emitted events (JSON for polling fallback)
/demo/emit                  → API: emit an event (POST)
/demo/reset                 → API: clear demo data (POST)
/demo/schema                → API: current schema (JSON)
/contact                    → Contact/inquiry form
/docs                       → Links out to GitHub README
```

### Navigation

```
[EventEngine Logo]    How It Works    Features    Demo    Pricing    [Contact Us]
```

---

## 4. Database Schema

### Demo-Specific Tables

EventEngine's `event_engine_outbox_events` table is used directly. Add one table for demo session management:

```ruby
# db/migrate/xxx_create_demo_sessions.rb
class CreateDemoSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :demo_sessions do |t|
      t.string :session_token, null: false, index: { unique: true }
      t.integer :events_emitted, default: 0
      t.datetime :expires_at, null: false
      t.timestamps
    end

    # Add session scoping to outbox events
    add_column :event_engine_outbox_events, :demo_session_token, :string
    add_index :event_engine_outbox_events, :demo_session_token
  end
end
```

### Contact/Inquiry Table

```ruby
class CreateInquiries < ActiveRecord::Migration[7.2]
  def change
    create_table :inquiries do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :company
      t.string :inquiry_type, default: "general"  # general, demo, implementation
      t.text :message
      t.timestamps
    end
  end
end
```

---

## 5. Landing Page — Section-by-Section Spec

The entire landing page is a single scrollable page with anchor sections. Each section below includes layout direction, copy guidance, and functional requirements.

---

### Section 1: Hero

**Layout:** Full-viewport height. Dark background (slate-900 or similar). Centered content.

**Content:**
- **Badge** (top): `Open Source · MIT Licensed` (subtle pill badge)
- **Headline**: "Stop Losing Events. Start Trusting Your Pipeline."
- **Subheadline**: "EventEngine is a schema-first event pipeline for Rails. Define events with a Ruby DSL, persist through the outbox pattern, and deliver through Kafka or any transport — with zero events dropped."
- **CTA buttons**:
  - Primary: `Try the Live Demo →` (links to `/demo`)
  - Secondary: `View on GitHub` (links to repo)
- **Visual**: Animated code snippet or terminal showing:
  ```ruby
  EventEngine.order_placed(order: @order)
  # => Validated ✓ → Outbox ✓ → Published ✓ → Kafka ✓
  ```
  Use a typing animation (Stimulus controller) that shows each step appearing with check marks.

**Technical notes:**
- Typing animation: Stimulus controller with `data-step` attributes and CSS transitions
- Background: Consider subtle grid pattern or gradient, not a stock photo

---

### Section 2: Problem / Solution

**Layout:** Two-column on desktop, stacked on mobile. Left = problem, right = solution.

**Content — Problem column:**
- Header: "Event Systems That Break in Production"
- Three pain-point cards:
  1. **Lost events** — "Fire-and-forget publishing means when Kafka is down, events vanish."
  2. **Schema chaos** — "No contract between producers and consumers. Breaking changes ship silently."
  3. **Debugging nightmares** — "When something goes wrong, there's no audit trail. No retry. No visibility."

**Content — Solution column:**
- Header: "EventEngine Makes Events Reliable"
- Three solution cards (mirror the pain points):
  1. **Outbox pattern** — "Events persist to your database first. Publishing happens after. Nothing is lost."
  2. **Schema-first** — "A compiled schema file is your contract. Drift detection catches breaking changes in CI."
  3. **Full observability** — "Every event is in the outbox. Retries, dead letters, and a dashboard — built in."

**Technical notes:**
- Cards should have subtle icons (Heroicons or similar)
- Consider a connecting line/arrow between problem → solution pairs

---

### Section 3: How It Works

**Layout:** Horizontal stepper/pipeline visualization. Five steps connected by arrows/lines.

**Content — Five Steps:**

```
 ┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
 │  DEFINE  │ ──→ │ COMPILE  │ ──→ │   BOOT   │ ──→ │   EMIT   │ ──→ │ PUBLISH  │
 └──────────┘     └──────────┘     └──────────┘     └──────────┘     └──────────┘
```

Each step expands on click/hover to show detail:

1. **Define** — "Write event definitions using a clean Ruby DSL."
   ```ruby
   class OrderPlaced < EventEngine::EventDefinition
     input :order
     event_name :order_placed
     event_type :domain
     required_payload :total, from: :order, attr: :total
     required_payload :customer_id, from: :order, attr: :customer_id
   end
   ```

2. **Compile** — "Run a rake task to compile definitions into a canonical schema file."
   ```bash
   bin/rails event_engine:schema:dump
   # => Wrote db/event_schema.rb (2 events, 3 versions)
   ```

3. **Boot** — "At Rails boot, the schema file loads into the registry and installs helper methods."
   ```ruby
   # Automatic — no setup code needed
   EventEngine.order_placed  # method exists at boot
   EventEngine.user_signed_up  # method exists at boot
   ```

4. **Emit** — "Call the helper method. The event is validated, built, and persisted to the outbox."
   ```ruby
   EventEngine.order_placed(order: @order)
   # Validates inputs, builds payload, writes to outbox
   ```

5. **Publish** — "The outbox publisher sends events to your transport. Failures retry automatically."
   ```ruby
   # Publishes to Kafka, retries on failure, dead-letters after max_attempts
   ```

**Technical notes:**
- Use a Stimulus controller to handle expand/collapse on each step
- On mobile, stack vertically with a downward arrow/line
- Consider subtle animation: each step "lights up" in sequence when the section scrolls into view (IntersectionObserver)

---

### Section 4: Features Grid

**Layout:** 3-column grid on desktop, 2 on tablet, 1 on mobile. Six feature cards.

**Cards:**

1. **Ruby DSL**
   - Icon: code brackets `</>`
   - Description: "Define events with a clean, declarative Ruby DSL. Inputs, payloads, types — all in one class."

2. **Outbox Pattern**
   - Icon: database/shield
   - Description: "Events are persisted to your database before publishing. If your transport is down, events are safe."

3. **Schema Versioning**
   - Icon: git branch/version
   - Description: "SHA256 fingerprinting detects payload changes and auto-increments versions. Old consumers keep working."

4. **Drift Detection**
   - Icon: warning/check
   - Description: "CI rake tasks compare your DSL definitions against the committed schema file. Breaking changes are caught before deploy."

5. **Dead Letter Handling**
   - Icon: retry/loop
   - Description: "Failed events retry up to `max_attempts` then move to a dead-letter queue. Inspect and replay from the dashboard."

6. **Pluggable Transports**
   - Icon: plug/connection
   - Description: "Ship with InMemory (dev), Kafka (production), or write your own. One interface: `publish(event)`."

**Optional 7th card (full-width below grid):**

7. **Built-in Dashboard**
   - Description: "Mount the engine and get a dashboard showing event throughput, outbox depth, dead letters, and schema versions. No setup required."
   - Include a screenshot/mockup of the dashboard

---

### Section 5: Interactive Demo CTA (Mid-page)

**Layout:** Full-width banner. Dark background with accent color.

**Content:**
- Headline: "See It Working. Right Now."
- Subtext: "No signup. No install. Emit real events, watch them flow through the pipeline, and inspect the outbox — all in your browser."
- CTA: `Launch the Demo →` (links to `/demo`)

---

### Section 6: Code Showcase

**Layout:** Tabbed code viewer. Three tabs showing real code.

**Tabs:**

1. **Define an Event**
   ```ruby
   class OrderPlaced < EventEngine::EventDefinition
     input :order
     optional_input :coupon

     event_name :order_placed
     event_type :domain

     required_payload :order_id, from: :order, attr: :id
     required_payload :total, from: :order, attr: :total
     required_payload :currency, from: :order, attr: :currency
     optional_payload :coupon_code, from: :coupon, attr: :code
   end
   ```

2. **Emit an Event**
   ```ruby
   # In your controller, service, or model callback
   order = Order.create!(params)

   EventEngine.order_placed(
     order: order,
     coupon: applied_coupon,
     metadata: { request_id: request.request_id }
   )
   ```

3. **Configure**
   ```ruby
   # config/initializers/event_engine.rb
   EventEngine.configure do |config|
     config.delivery_adapter = :active_job
     config.transport = EventEngine::Transports::Kafka.new(
       producer: EventEngine::KafkaProducer.new(client: kafka)
     )
     config.batch_size = 100
     config.max_attempts = 5
     config.retention_period = 30.days
   end
   ```

**Technical notes:**
- Use a Stimulus controller for tab switching
- Syntax highlighting via a `<pre><code>` block with Tailwind prose or a lightweight highlighter (Rouge on server-side, or highlight.js)

---

### Section 7: Social Proof / Trust (If Available)

**Layout:** Centered, subtle section.

**Content (populate as available):**
- GitHub stars count (fetched via API or hardcoded)
- "Used in production at [company]" logos
- Testimonial quotes
- If none available yet, skip this section or replace with: "Built by Rails developers, for Rails developers. Open source and MIT licensed."

---

### Section 8: Pricing

**Layout:** Three-column pricing cards. Center card emphasized.

**Cards:**

1. **Open Source** — Free
   - EventEngine gem (MIT)
   - Full DSL, outbox pattern, transports
   - GitHub Issues support
   - Community documentation
   - CTA: `View on GitHub`

2. **Implementation Package** — Contact for pricing (featured/highlighted card)
   - Everything in Open Source
   - EventEngine integrated into your Rails app
   - Event definitions designed for your domain
   - Kafka/transport setup and configuration
   - Schema CI pipeline setup
   - 2 weeks of post-launch support
   - CTA: `Get in Touch`

3. **Ongoing Support** — Monthly retainer
   - Everything in Implementation
   - Dedicated Slack channel
   - Event schema reviews on PRs
   - Performance monitoring and tuning
   - Priority bug fixes
   - Architecture advisory
   - CTA: `Contact Us`

**Note:** Pricing amounts can be added later. For now, use "Contact for pricing" on paid tiers.

---

### Section 9: FAQ

**Layout:** Accordion (expand/collapse). Stimulus controller.

**Questions:**

1. **Is EventEngine production-ready?**
   "EventEngine v0.1.0 is stable and tested. It implements the outbox pattern which is a proven reliability strategy used by companies like Shopify and Stripe."

2. **Do I need Kafka?**
   "No. EventEngine ships with InMemory (for dev/test) and Kafka transports, but you can write a custom transport in ~10 lines of Ruby. Any system that can receive messages works."

3. **How does schema versioning work?**
   "When you change a payload field, EventEngine detects the change via SHA256 fingerprinting and assigns a new version number. Old versions are preserved, so existing consumers continue working."

4. **What happens when publishing fails?**
   "The event stays in the outbox. The publisher retries on the next run. After `max_attempts` failures, the event is dead-lettered. You can inspect and replay dead-lettered events from the dashboard or via rake tasks."

5. **Can I use this with Sidekiq / Solid Queue / GoodJob?**
   "Yes. EventEngine uses ActiveJob, so it works with any ActiveJob backend."

6. **What Rails versions are supported?**
   "Rails 7.1+ is required."

---

### Section 10: Footer CTA + Footer

**Footer CTA (full-width banner above footer):**
- Headline: "Ready to Make Your Events Reliable?"
- CTA: `Get Started` (links to GitHub) | `Talk to Us` (links to `/contact`)

**Footer:**
- Links: GitHub, Documentation, Contact, Changelog
- "Built with EventEngine" (meta — this site runs on EventEngine)
- Copyright

---

## 6. Interactive Demo — The Centerpiece

This is the key differentiator. Visitors interact with a **live instance of EventEngine** running on the promo site itself.

### Demo Layout

The demo page (`/demo`) is a full-screen app-like experience with three panels:

```
┌─────────────────────────────────────────────────────────────────┐
│  [← Back to Home]           Event Playground           [Reset] │
├───────────────────────┬─────────────────────────────────────────┤
│                       │                                         │
│   EVENT BUILDER       │         LIVE EVENT STREAM               │
│   (left panel)        │         (right panel)                   │
│                       │                                         │
│   Choose event type   │   Real-time feed showing events as     │
│   Fill in inputs      │   they flow through the pipeline:      │
│   Click "Emit"        │                                         │
│                       │   ┌─────────────────────────────┐      │
│   ┌───────────────┐   │   │ 12:03:45 order_placed       │      │
│   │ Event Type:   │   │   │ ✓ Validated → ✓ Outbox →    │      │
│   │ [order_placed]│   │   │ ✓ Published → ✓ Delivered   │      │
│   │               │   │   └─────────────────────────────┘      │
│   │ order_id: [42]│   │   ┌─────────────────────────────┐      │
│   │ total: [99.99]│   │   │ 12:03:40 user_signed_up     │      │
│   │ currency:[USD]│   │   │ ✓ Validated → ✓ Outbox →    │      │
│   │               │   │   │ ✗ Publish FAILED (attempt 1)│      │
│   │ [Emit Event]  │   │   └─────────────────────────────┘      │
│   └───────────────┘   │                                         │
│                       │                                         │
├───────────────────────┴─────────────────────────────────────────┤
│                      OUTBOX INSPECTOR                           │
│  ┌────┬──────────────┬─────────┬──────────┬────────┬─────────┐ │
│  │ ID │ Event        │ Version │ Status   │ Tries  │ Payload │ │
│  ├────┼──────────────┼─────────┼──────────┼────────┼─────────┤ │
│  │ 7  │ order_placed │ 1       │ ✓ Publd  │ 1      │ {…}     │ │
│  │ 6  │ user_signed  │ 1       │ ✗ Failed │ 1      │ {…}     │ │
│  │ 5  │ order_placed │ 1       │ ✓ Publd  │ 1      │ {…}     │ │
│  └────┴──────────────┴─────────┴──────────┴────────┴─────────┘ │
│                                                                 │
│  [Schema File]  [Dead Letters (1)]  [Retry Failed]              │
└─────────────────────────────────────────────────────────────────┘
```

### Demo Features — Detailed Spec

#### 6.1 Event Builder (Left Panel)

**Purpose:** Let visitors construct and emit events using EventEngine's actual DSL-compiled schemas.

**UI:**
- Dropdown to select event type (populated from SchemaRegistry)
- When an event type is selected, the form dynamically renders input fields based on the schema's `payload_fields`
  - Required fields have a red asterisk
  - Optional fields are clearly marked
  - Field types are inferred (number inputs for `id`/`total`, text for strings)
- "Emit Event" button (primary CTA, prominent)
- "Simulate Failure" toggle — when ON, the transport intentionally raises an error so the visitor can see retry/dead-letter behavior
- Event counter: "You've emitted X events this session"

**Behavior:**
1. Visitor fills in fields
2. Clicks "Emit Event"
3. POST to `/demo/emit` with `{ event_type: "order_placed", inputs: { order_id: 42, total: 99.99 } }`
4. Server creates stub input objects from the form data, calls `EventEngine.order_placed(order: stub)`
5. Event appears in the live stream and outbox inspector via Turbo Stream

**Technical implementation:**
- Stimulus controller: `event-builder` — handles form rendering based on selected schema, form submission via Turbo
- Use `turbo_frame` for the form so it can swap cleanly on event type change

#### 6.2 Live Event Stream (Right Panel)

**Purpose:** Real-time visualization of events flowing through the pipeline.

**UI:**
- Reverse-chronological feed (newest on top)
- Each event card shows:
  - Timestamp
  - Event name + version
  - Pipeline steps with status indicators that animate in sequence:
    - `Validated ✓` (appears immediately)
    - `Outbox ✓` (appears after ~300ms)
    - `Published ✓` or `Published ✗` (appears after ~600ms)
    - `Delivered ✓` (appears after ~900ms)
  - If failure: red indicator with error message and attempt count
- Max ~20 events shown (older ones fade out / removed from DOM)

**Behavior:**
1. When an event is emitted, the server broadcasts a Turbo Stream `prepend` to the event stream
2. Each pipeline step is broadcast as a separate Turbo Stream `replace` on the event card, with staggered timing to create the animation of "flowing through the pipeline"
3. Failed events show a retry button that triggers republishing

**Technical implementation:**
- ActionCable channel: `DemoStreamChannel` (scoped by demo session token)
- Turbo Stream broadcasts from the server (after_create callback + ActiveJob for staggered updates)
- Stimulus controller: `event-stream` — handles auto-scroll, event limit enforcement
- CSS transitions on step indicators (opacity/transform) for smooth appearance

#### 6.3 Outbox Inspector (Bottom Panel)

**Purpose:** Show the actual database state of the outbox — the core of the outbox pattern.

**UI:**
- Table view of `event_engine_outbox_events` (filtered to current demo session)
- Columns: ID, Event Name, Version, Status (published/unpublished/dead-lettered), Attempts, Payload (expandable JSON), Occurred At, Published At
- Color-coded rows: green = published, yellow = pending, red = dead-lettered
- Tabs below the table:
  - **All Events** — full outbox view
  - **Schema File** — shows the actual `db/event_schema.rb` contents with syntax highlighting
  - **Dead Letters** — filtered view of dead-lettered events with "Retry" and "Retry All" buttons

**Behavior:**
- Table updates in real-time via Turbo Streams (row appended on emit, row updated on publish/fail)
- Clicking a row expands to show full payload JSON and metadata
- "Retry" button on dead-lettered events calls `OutboxPublisher` for that specific event
- "Schema File" tab fetches and displays the compiled schema file contents

**Technical implementation:**
- Turbo Frame for the table body (or Turbo Stream append/replace for individual rows)
- Stimulus controller: `outbox-inspector` — handles row expansion, tab switching
- Schema display: read `db/event_schema.rb` on server, render with syntax highlighting

#### 6.4 Demo Session Management

**Purpose:** Isolate each visitor's demo data so they only see their own events.

**Implementation:**
- On first visit to `/demo`, generate a `demo_session_token` (SecureRandom.hex) and store in a signed cookie
- Create a `DemoSession` record
- All events emitted include `demo_session_token` in metadata
- All queries in the demo are scoped: `OutboxEvent.where(demo_session_token: token)`
- Sessions expire after 1 hour
- Background job cleans up expired sessions and their events (runs hourly)
- Rate limit: max 50 events per session (prevent abuse)

#### 6.5 Demo Event Definitions

Create 3 pre-built event types for the demo that represent a realistic e-commerce scenario:

```ruby
# app/event_definitions/demo/order_placed.rb
class Demo::OrderPlaced < EventEngine::EventDefinition
  input :order
  optional_input :coupon

  event_name :order_placed
  event_type :domain

  required_payload :order_id, from: :order, attr: :id
  required_payload :total, from: :order, attr: :total
  required_payload :currency, from: :order, attr: :currency
  required_payload :customer_email, from: :order, attr: :customer_email
  optional_payload :coupon_code, from: :coupon, attr: :code
end

# app/event_definitions/demo/user_signed_up.rb
class Demo::UserSignedUp < EventEngine::EventDefinition
  input :user

  event_name :user_signed_up
  event_type :domain

  required_payload :user_id, from: :user, attr: :id
  required_payload :email, from: :user, attr: :email
  required_payload :name, from: :user, attr: :name
end

# app/event_definitions/demo/payment_processed.rb
class Demo::PaymentProcessed < EventEngine::EventDefinition
  input :payment

  event_name :payment_processed
  event_type :domain

  required_payload :payment_id, from: :payment, attr: :id
  required_payload :amount, from: :payment, attr: :amount
  required_payload :currency, from: :payment, attr: :currency
  required_payload :status, from: :payment, attr: :status
end
```

#### 6.6 Stub Input Objects

Since the demo doesn't have real Order/User/Payment models, create lightweight structs:

```ruby
# app/models/demo/stub_input.rb
module Demo
  class StubInput
    def initialize(attributes = {})
      attributes.each do |key, value|
        define_singleton_method(key) { value }
      end
    end
  end
end
```

When a visitor submits the form, the controller builds:
```ruby
stub = Demo::StubInput.new(params[:inputs])
EventEngine.order_placed(order: stub)
```

#### 6.7 Simulate Failure Mode

A toggle in the UI that switches the transport to a `FailingTransport`:

```ruby
# app/models/demo/failing_transport.rb
module Demo
  class FailingTransport
    def publish(event)
      raise StandardError, "Simulated transport failure — Kafka unreachable"
    end
  end
end
```

When enabled:
- Events still persist to outbox (that's the point of the outbox pattern!)
- Publishing fails, attempts increment
- After max_attempts, event is dead-lettered
- Visitor sees the retry and dead-letter flow in action
- A callout box explains: "This is the outbox pattern in action. Even though the transport failed, your event is safe in the database. It will be retried automatically."

---

## 7. Routes & Controllers

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # Landing page
  root "pages#home"

  # Contact
  resources :inquiries, only: [:new, :create], path: "contact"

  # Interactive demo
  namespace :demo do
    get "/", to: "playground#show"
    post "emit", to: "playground#emit"
    post "reset", to: "playground#reset"
    post "retry/:id", to: "playground#retry_event", as: :retry_event
    get "schema", to: "playground#schema"
    patch "transport", to: "playground#toggle_transport"
  end

  # Mount EventEngine dashboard (optional, for showing off)
  mount EventEngine::Engine => "/event_engine"
end
```

### Controllers

#### `PagesController`
```
GET /  → pages#home
```
- Renders the landing page
- No authentication required

#### `InquiriesController`
```
GET  /contact → inquiries#new
POST /contact → inquiries#create
```
- Renders and processes the contact form
- Sends notification email on create
- Redirects back with flash message

#### `Demo::PlaygroundController`
```
GET   /demo             → playground#show
POST  /demo/emit        → playground#emit
POST  /demo/reset       → playground#reset
POST  /demo/retry/:id   → playground#retry_event
GET   /demo/schema      → playground#schema
PATCH /demo/transport   → playground#toggle_transport
```

Detailed behavior:

**`show`** — Initializes demo session (cookie + DemoSession record). Loads schemas from registry, loads existing events for this session. Renders the three-panel layout.

**`emit`** — Accepts event type + input values. Builds stub inputs. Calls EventEngine helper. Broadcasts Turbo Streams for the live feed and outbox table. Returns turbo_stream response. Rate-limited to 50 events per session.

**`reset`** — Deletes all outbox events for this session. Resets counter. Broadcasts Turbo Stream to clear the feed and table.

**`retry_event`** — Finds a dead-lettered event by ID (scoped to session). Resets attempts and dead_lettered_at. Runs publisher for that event. Broadcasts updated state.

**`schema`** — Returns the current `db/event_schema.rb` file contents as JSON (for the schema viewer tab).

**`toggle_transport`** — Toggles between InMemoryTransport and FailingTransport for this session. Stores choice in session cookie.

---

## 8. Models

### `DemoSession`
```ruby
class DemoSession < ApplicationRecord
  validates :session_token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :active, -> { where("expires_at > ?", Time.current) }
  scope :expired, -> { where("expires_at <= ?", Time.current) }

  before_validation :set_defaults, on: :create

  def expired?
    expires_at <= Time.current
  end

  def events
    EventEngine::OutboxEvent.where(demo_session_token: session_token)
  end

  def rate_limited?
    events_emitted >= 50
  end

  private

  def set_defaults
    self.session_token ||= SecureRandom.hex(16)
    self.expires_at ||= 1.hour.from_now
  end
end
```

### `Inquiry`
```ruby
class Inquiry < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :inquiry_type, inclusion: { in: %w[general demo implementation] }

  after_create :send_notification

  private

  def send_notification
    InquiryMailer.new_inquiry(self).deliver_later
  end
end
```

### Background Jobs

```ruby
# app/jobs/demo_cleanup_job.rb
class DemoCleanupJob < ApplicationJob
  queue_as :default

  def perform
    expired_sessions = DemoSession.expired
    expired_sessions.find_each do |session|
      session.events.delete_all
      session.destroy
    end
  end
end
```

Schedule via `config/recurring.yml` (Solid Queue) or equivalent:
```yaml
demo_cleanup:
  class: DemoCleanupJob
  schedule: every hour
```

---

## 9. Views & Components

### Layout

Use Jumpstart's application layout. Override with:
- Remove Jumpstart's default navbar for the landing page (use custom nav)
- Keep Jumpstart's navbar for authenticated pages (contact form, etc.)
- Create a `landing` layout variant

### Partials / Components

```
app/views/
├── layouts/
│   └── landing.html.erb              # Custom layout for the sales page
├── pages/
│   └── home.html.erb                 # Landing page (orchestrates sections)
├── pages/sections/
│   ├── _hero.html.erb
│   ├── _problem_solution.html.erb
│   ├── _how_it_works.html.erb
│   ├── _features.html.erb
│   ├── _demo_cta.html.erb
│   ├── _code_showcase.html.erb
│   ├── _pricing.html.erb
│   ├── _faq.html.erb
│   └── _footer_cta.html.erb
├── demo/playground/
│   ├── show.html.erb                 # Three-panel demo layout
│   ├── _event_builder.html.erb       # Left panel
│   ├── _event_stream.html.erb        # Right panel
│   ├── _outbox_inspector.html.erb    # Bottom panel
│   ├── _event_card.html.erb          # Single event in the stream
│   ├── _outbox_row.html.erb          # Single row in the outbox table
│   ├── _schema_viewer.html.erb       # Schema file display
│   └── _pipeline_step.html.erb       # Animated step indicator
├── inquiries/
│   ├── new.html.erb
│   └── create.html.erb               # Thank-you page
└── shared/
    ├── _navbar.html.erb              # Landing page navbar
    ├── _code_block.html.erb          # Syntax-highlighted code partial
    └── _step_indicator.html.erb      # Reusable step component
```

### Stimulus Controllers

```
app/javascript/controllers/
├── typing_animation_controller.js    # Hero code typing effect
├── step_expander_controller.js       # How It Works step expansion
├── tab_switcher_controller.js        # Code showcase tabs
├── faq_accordion_controller.js       # FAQ expand/collapse
├── event_builder_controller.js       # Demo: form field rendering
├── event_stream_controller.js        # Demo: auto-scroll, event limit
├── outbox_inspector_controller.js    # Demo: row expansion, tabs
├── scroll_reveal_controller.js       # Animate sections on scroll
└── failure_toggle_controller.js      # Demo: simulate failure switch
```

---

## 10. Real-Time Infrastructure

### ActionCable Setup

```ruby
# app/channels/demo_stream_channel.rb
class DemoStreamChannel < ApplicationCable::Channel
  def subscribed
    stream_from "demo_stream_#{params[:session_token]}"
  end
end
```

### Turbo Stream Broadcasts

After an event is emitted, broadcast a sequence of updates:

```ruby
# app/services/demo/event_broadcaster.rb
module Demo
  class EventBroadcaster
    def initialize(event, session_token)
      @event = event
      @session_token = session_token
      @stream = "demo_stream_#{session_token}"
    end

    def broadcast_lifecycle
      # Step 1: Immediately — event created with "Validated" step
      broadcast_event_card(steps_completed: [:validated])

      # Step 2: After 300ms — "Outbox" step
      BroadcastStepJob.set(wait: 0.3.seconds).perform_later(
        @event.id, @session_token, :outbox
      )

      # Step 3: After 600ms — "Published" step (or failure)
      BroadcastStepJob.set(wait: 0.6.seconds).perform_later(
        @event.id, @session_token, :published
      )

      # Step 4: After 900ms — "Delivered" step (if published)
      BroadcastStepJob.set(wait: 0.9.seconds).perform_later(
        @event.id, @session_token, :delivered
      )

      # Also: append row to outbox table
      broadcast_outbox_row
    end

    private

    def broadcast_event_card(steps_completed:)
      Turbo::StreamsChannel.broadcast_prepend_to(
        @stream,
        target: "event-stream",
        partial: "demo/playground/event_card",
        locals: { event: @event, steps_completed: steps_completed }
      )
    end

    def broadcast_outbox_row
      Turbo::StreamsChannel.broadcast_prepend_to(
        @stream,
        target: "outbox-table-body",
        partial: "demo/playground/outbox_row",
        locals: { event: @event }
      )
    end
  end
end
```

### Staggered Step Broadcast Job

```ruby
# app/jobs/broadcast_step_job.rb
class BroadcastStepJob < ApplicationJob
  queue_as :default

  def perform(event_id, session_token, step)
    event = EventEngine::OutboxEvent.find(event_id)
    stream = "demo_stream_#{session_token}"

    Turbo::StreamsChannel.broadcast_replace_to(
      stream,
      target: "event-#{event.id}-step-#{step}",
      partial: "demo/playground/pipeline_step",
      locals: {
        event: event,
        step: step,
        completed: step_completed?(event, step)
      }
    )
  end

  private

  def step_completed?(event, step)
    case step
    when :outbox then event.persisted?
    when :published then event.published_at.present?
    when :delivered then event.published_at.present?
    else false
    end
  end
end
```

### Fallback (No WebSocket)

If ActionCable isn't available (some hosting configs), fall back to polling:

```javascript
// In event_stream_controller.js
if (!this.cableConnected) {
  this.pollInterval = setInterval(() => {
    fetch(`/demo/events?since=${this.lastEventId}`)
      .then(r => r.json())
      .then(events => this.appendEvents(events))
  }, 2000)
}
```

---

## 11. EventEngine Integration

### Gemfile

```ruby
gem "event_engine", github: "tylercschneider/event_engine", branch: "main"
```

### Initializer

```ruby
# config/initializers/event_engine.rb
EventEngine.configure do |config|
  config.delivery_adapter = :inline
  config.transport = EventEngine::Transports::InMemoryTransport.new
  config.batch_size = 100
  config.max_attempts = 3   # Lower for demo so dead-lettering happens fast
end
```

### Schema Generation

After creating the three demo event definitions:

```bash
bin/rails event_engine:schema:dump
git add db/event_schema.rb
git commit -m "Add demo event schemas"
```

### Demo-Specific Transport Wrapper

To support per-session transport switching (normal vs. failing):

```ruby
# app/services/demo/session_transport.rb
module Demo
  class SessionTransport
    def initialize(session)
      @session = session
    end

    def publish(event)
      if @session[:simulate_failure]
        raise StandardError, "Simulated failure: Kafka broker unreachable (this is intentional!)"
      else
        EventEngine.configuration.transport.publish(event)
      end
    end
  end
end
```

The demo controller temporarily swaps the transport for the emit call:

```ruby
# In Demo::PlaygroundController#emit
original_transport = EventEngine.configuration.transport
EventEngine.configuration.transport = Demo::SessionTransport.new(session)
EventEngine.public_send(event_type, **inputs)
ensure
  EventEngine.configuration.transport = original_transport
```

> **Note:** This approach has a concurrency issue if multiple demo users are active simultaneously. A better approach is to use a thread-local or request-local transport. Consider wrapping in `RequestStore` or `ActiveSupport::CurrentAttributes`:

```ruby
# app/models/demo/current.rb
module Demo
  class Current < ActiveSupport::CurrentAttributes
    attribute :transport
  end
end
```

Then modify EventEngine's delivery to check `Demo::Current.transport` first (or use middleware). Alternatively, fork the event emission to happen in a dedicated thread with its own transport. The simplest v1 approach: always use InMemoryTransport, and have a separate "Simulate Failure" button that just directly demonstrates dead-lettering by manually creating a failed event record.

### Extending OutboxEvent for Demo Scoping

```ruby
# config/initializers/event_engine_extensions.rb
Rails.application.config.to_prepare do
  EventEngine::OutboxEvent.class_eval do
    scope :for_demo_session, ->(token) { where(demo_session_token: token) }
  end
end
```

Alternatively, add `demo_session_token` as a metadata field passed during emission and query via JSON:

```ruby
EventEngine.order_placed(
  order: stub,
  metadata: { demo_session_token: session_token }
)

# Query:
EventEngine::OutboxEvent.where("metadata->>'demo_session_token' = ?", token)
```

This avoids modifying EventEngine's migration. Use this approach.

---

## 12. Copy & Messaging

### Brand Voice

- **Confident but not arrogant** — "EventEngine solves this" not "EventEngine is the best"
- **Technical but accessible** — Show real code, but explain what it does
- **Honest** — v0.1.0, MIT licensed, growing. Don't oversell.
- **Developer-to-developer** — Write like you're explaining it to a peer at a meetup, not a marketing brochure

### Key Messages

1. **Events shouldn't be fire-and-forget.** The outbox pattern means they're persisted before publishing. Nothing is lost.
2. **Schema drift breaks consumers.** A compiled schema file is your contract. CI catches changes before deploy.
3. **You shouldn't build this yourself.** The outbox pattern, retry logic, dead-lettering, versioning — it's a lot of subtlety. EventEngine packages it into a clean DSL.
4. **See it working, right now.** The interactive demo is not a simulation. It's EventEngine running in production.

### Headline Options (pick one per section or A/B test)

**Hero:**
- "Stop Losing Events. Start Trusting Your Pipeline."
- "Schema-First Events for Rails. Reliable by Default."
- "Your Events Deserve an Outbox."

**Demo CTA:**
- "See It Working. Right Now."
- "Try EventEngine in 30 Seconds. No Signup."

---

## 13. Design Direction

### Visual Style

- **Dark mode primary** — Slate/zinc-900 backgrounds with white/gray text. Developers prefer dark UIs.
- **Accent color** — Emerald or cyan (stands out against dark bg, feels "technical")
- **Code is the hero** — Large, syntax-highlighted code blocks. The DSL is the selling point.
- **Minimal chrome** — No stock photos. No decorative illustrations. Clean whitespace.
- **Monospace for code** — Use a web font like JetBrains Mono or Fira Code for code snippets

### Tailwind Theme Extensions

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        brand: {
          50: '#ecfdf5',   // emerald-50
          500: '#10b981',  // emerald-500
          600: '#059669',  // emerald-600
          700: '#047857',  // emerald-700
        }
      },
      fontFamily: {
        mono: ['JetBrains Mono', 'Fira Code', 'monospace'],
      }
    }
  }
}
```

### Layout Principles

- Max content width: `max-w-6xl` (1152px)
- Section padding: `py-24` desktop, `py-16` mobile
- Card style: `bg-slate-800 border border-slate-700 rounded-xl p-6`
- Code blocks: `bg-slate-950 rounded-lg p-4 font-mono text-sm`

### Responsive Breakpoints

- Mobile first (Tailwind default)
- `sm:` (640px) — Minor adjustments
- `md:` (768px) — Two-column layouts kick in
- `lg:` (1024px) — Full desktop layout
- Demo page: On mobile, stack panels vertically (builder → stream → inspector)

### Animation Guidelines

- Use `transition-all duration-300` for interactive elements
- Scroll-triggered reveals: `opacity-0 translate-y-4 → opacity-100 translate-y-0` (IntersectionObserver via Stimulus)
- Pipeline steps: sequential reveal with staggered delays
- Keep animations subtle and purposeful — this is a developer tool, not a marketing spectacle

---

## 14. Deployment

### Recommended: Hatchbox or Render

Both support:
- Rails with PostgreSQL
- ActionCable (WebSockets)
- Background workers (Solid Queue / Sidekiq)
- Custom domains + SSL

### Hatchbox Setup

```
App Server: 1x (512MB+ RAM)
Worker: 1x (for background jobs)
Database: PostgreSQL (managed)
Redis: For ActionCable adapter + caching
```

### Environment Config

```ruby
# config/cable.yml
production:
  adapter: redis
  url: <%= ENV.fetch("REDIS_URL") %>

# config/environments/production.rb
config.action_cable.allowed_request_origins = [
  "https://eventengine.dev",       # or whatever domain
  "https://www.eventengine.dev"
]
```

### Domain Suggestions

- `eventengine.dev`
- `eventengine.io`
- `geteventengine.com`
- `eventenginerails.com`

### Post-Deploy Checklist

- [ ] `bin/rails db:migrate`
- [ ] `bin/rails event_engine:schema:dump` (or ensure schema file is committed)
- [ ] Verify ActionCable connects (check browser console for WebSocket)
- [ ] Test demo flow end-to-end
- [ ] Set up recurring DemoCleanupJob
- [ ] Configure exception tracking (Honeybadger, Sentry, etc.)
- [ ] Set up uptime monitoring

---

## 15. Build Order

Recommended sequence for the developer building this. Each phase is independently deployable.

### Phase 1: Foundation (Day 1)

1. Create Jumpstart Rails app with PostgreSQL
2. Add `event_engine` gem
3. Run migrations (Jumpstart + EventEngine)
4. Create the 3 demo event definitions
5. Generate schema file
6. Create `DemoSession` model + migration
7. Create `Inquiry` model + migration
8. Configure EventEngine initializer
9. Verify: `EventEngine.order_placed(order: stub)` works in console

### Phase 2: Landing Page (Day 2-3)

1. Create `landing` layout (dark theme, custom nav)
2. Build hero section with static code block (animate later)
3. Build problem/solution section
4. Build "How It Works" stepper (static first, interactions later)
5. Build features grid
6. Build code showcase with tabs
7. Build pricing section
8. Build FAQ accordion
9. Build footer CTA + footer
10. Responsive pass on all sections

### Phase 3: Interactive Demo — Core (Day 4-5)

1. Build demo layout (three panels)
2. Build Event Builder form (hardcoded fields first)
3. Create `Demo::PlaygroundController` with `show` and `emit`
4. Create `Demo::StubInput` model
5. Wire up emit: form → controller → EventEngine → outbox
6. Build Outbox Inspector table (static query, full page reload)
7. Verify: can emit events and see them in the table

### Phase 4: Interactive Demo — Real-Time (Day 6-7)

1. Set up ActionCable + DemoStreamChannel
2. Add Turbo Stream broadcasts for outbox table (append on emit)
3. Build Live Event Stream panel with Turbo Stream prepend
4. Add staggered pipeline step animations (BroadcastStepJob)
5. Add "Simulate Failure" toggle + FailingTransport
6. Add dead-letter view + retry button
7. Add schema viewer tab
8. Add session reset button
9. Verify: full real-time flow works

### Phase 5: Polish (Day 8)

1. Add typing animation to hero
2. Add scroll-reveal animations to landing sections
3. Add IntersectionObserver to "How It Works" stepper
4. Dynamic form fields in Event Builder (based on SchemaRegistry)
5. Rate limiting on demo (50 events/session)
6. DemoCleanupJob + recurring schedule
7. Contact form + InquiryMailer
8. SEO meta tags, Open Graph, favicon
9. Final responsive QA pass

### Phase 6: Deploy (Day 9)

1. Set up hosting (Hatchbox/Render)
2. Configure domain + SSL
3. Set up Redis for ActionCable
4. Deploy and verify
5. Set up monitoring/alerting

---

## 16. Out of Scope (v1)

Save these for later iterations:

- **User accounts / authentication** — The demo is anonymous. Jumpstart auth is there if needed later.
- **Blog / content marketing** — Add later for SEO
- **Analytics dashboard** — Track demo usage, conversion. Add later.
- **Multi-tenant demo** — Current approach uses session tokens. Good enough for v1.
- **Custom event definitions** — Visitors can't define their own events via UI (too complex for v1). They pick from 3 pre-built ones.
- **Webhook transport demo** — Would be cool to let visitors supply a webhook URL and see events delivered there. Save for v2.
- **Video walkthrough** — Record after site is live
- **A/B testing on copy** — After launch, once there's traffic
- **Billing / Stripe integration** — Jumpstart has this built in. Wire up when pricing is finalized.

---

## Appendix A: File Manifest

Every file the developer needs to create:

```
# Models
app/models/demo_session.rb
app/models/inquiry.rb
app/models/demo/stub_input.rb

# Event definitions
app/event_definitions/demo/order_placed.rb
app/event_definitions/demo/user_signed_up.rb
app/event_definitions/demo/payment_processed.rb

# Controllers
app/controllers/pages_controller.rb          (modify Jumpstart default)
app/controllers/inquiries_controller.rb
app/controllers/demo/playground_controller.rb

# Channels
app/channels/demo_stream_channel.rb

# Jobs
app/jobs/demo_cleanup_job.rb
app/jobs/broadcast_step_job.rb

# Services
app/services/demo/event_broadcaster.rb
app/services/demo/session_transport.rb
app/services/demo/failing_transport.rb

# Mailers
app/mailers/inquiry_mailer.rb

# Views — Layouts
app/views/layouts/landing.html.erb

# Views — Landing page
app/views/pages/home.html.erb
app/views/pages/sections/_hero.html.erb
app/views/pages/sections/_problem_solution.html.erb
app/views/pages/sections/_how_it_works.html.erb
app/views/pages/sections/_features.html.erb
app/views/pages/sections/_demo_cta.html.erb
app/views/pages/sections/_code_showcase.html.erb
app/views/pages/sections/_pricing.html.erb
app/views/pages/sections/_faq.html.erb
app/views/pages/sections/_footer_cta.html.erb

# Views — Demo
app/views/demo/playground/show.html.erb
app/views/demo/playground/_event_builder.html.erb
app/views/demo/playground/_event_stream.html.erb
app/views/demo/playground/_outbox_inspector.html.erb
app/views/demo/playground/_event_card.html.erb
app/views/demo/playground/_outbox_row.html.erb
app/views/demo/playground/_schema_viewer.html.erb
app/views/demo/playground/_pipeline_step.html.erb

# Views — Contact
app/views/inquiries/new.html.erb
app/views/inquiries/create.html.erb
app/views/inquiry_mailer/new_inquiry.html.erb

# Stimulus controllers
app/javascript/controllers/typing_animation_controller.js
app/javascript/controllers/step_expander_controller.js
app/javascript/controllers/tab_switcher_controller.js
app/javascript/controllers/faq_accordion_controller.js
app/javascript/controllers/event_builder_controller.js
app/javascript/controllers/event_stream_controller.js
app/javascript/controllers/outbox_inspector_controller.js
app/javascript/controllers/scroll_reveal_controller.js
app/javascript/controllers/failure_toggle_controller.js

# Migrations
db/migrate/xxx_create_demo_sessions.rb
db/migrate/xxx_create_inquiries.rb

# Config
config/initializers/event_engine.rb
config/routes.rb                              (modify)
config/recurring.yml                          (if Solid Queue)

# Schema
db/event_schema.rb                            (generated)
```

---

## Appendix B: Concurrency Note

The demo's "Simulate Failure" feature swaps the global transport, which is not thread-safe. For v1, the simplest safe approach:

**Option A (Recommended for v1):** Don't swap the transport at all. Instead, the "Simulate Failure" button creates an event record directly in the outbox with `attempts: max_attempts` and `dead_lettered_at: Time.current`, demonstrating what a failed event looks like. Add a "Retry" button that clears these fields and runs the publisher. This sidesteps the concurrency issue entirely while still demonstrating the dead-letter flow.

**Option B (v2):** Use `ActiveSupport::CurrentAttributes` to store a per-request transport override, and modify EventEngine to check for it. This is cleaner but requires changes to the gem itself.
