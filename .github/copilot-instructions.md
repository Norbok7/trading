<!--
Repository-level Copilot instructions. These guidelines steer GitHub Copilot suggestions toward production‑ready,
full‑stack Rails patterns.
-->

# Copilot Instructions

Follow these rules when generating or completing code in this repository.

## Foundation & Environment

* Target **Rails 7.1** and **Ruby 3.3** syntax. Prefer Zeitwerk autoloading and `config.load_defaults "7.1"`.
* Lock Ruby & Node versions in `/.tool-versions` and invoke `bin/setup` for deterministic development.
* Store secrets in encrypted credentials (`rails credentials:edit`). Never hard‑code secrets or rely solely on ENV variables.

## Code Style & Conventions

* Conform to **RuboCop** + `rubocop-rails`; follow the community Rails Style Guide.
* Keep files ≤200 LOC and one responsibility; extract Services/Queries/Policies before classes grow.
* Use early returns, keyword arguments, and immutable data; avoid `and`/`or` for control flow.

## Architecture & Boundaries

* Maintain skinny controllers, views, and models; push business logic into POROs.
* Wrap UI fragments in **ViewComponent** classes for testable, reusable views.
* Organize domain code under `app/domains`, form objects under `app/forms`, serializers under `app/serializers`.

## Front‑End & Hotwire

* Default to **Hotwire (Turbo 8 + Stimulus)** for interactivity; reach for React/Vue only when needed.
* Bundle JS & CSS with `jsbundling-rails` + ESBuild, outputting to `app/assets/builds`.
* Broadcast Turbo Streams from models and define custom actions in `app/views/turbo_streams`.

## Data Layer

* Prevent N+1 queries with `includes` and the Bullet gem in development.
* Index every foreign key and commonly searched column.
* Prefer string‑backed `enum`s over integers for readability and safety.

## API & Serialization

* Serialize JSON via **jsonapi-serializer**; version endpoints under `/v1`, `/v2`, etc.
* Document endpoints with OpenAPI (RSwag) and publish via GitHub Pages.

## Testing & Quality Assurance

* Use **RSpec 5** + FactoryBot, Capybara, and `view_component-test`.
* Aim for 100 % critical‑path coverage and enforce tests & RuboCop in CI (GitHub Actions).

## Security

* Enable CSRF protection, use `same_site: :lax` cookies, and enforce HTTPS with HSTS.
* Validate complex payloads with strong parameters or `dry-validation`.
* Rotate secrets annually and scan dependencies with `bundler-audit`.

## Performance & Scalability

* Profile with `rack-mini-profiler`, cache aggressively, and store blobs on S3 via Active Storage.
* Offload blocking work to Sidekiq/GoodJob queues; target web request latency ≤ 200 ms.
* Monitor p99 latency and auto‑scale dynos/pods.

## Deployment & DevOps

* Automate CI→CD through GitHub Actions to Heroku/GCP/AWS; create Review Apps for every PR.
* Use zero‑downtime migrations and blue‑green releases.
* Emit logs in JSON and metrics to Prometheus/Grafana.

## Documentation & Collaboration

* Provide a three‑command `README.md` bootstrap and a `CONTRIBUTING.md` for PR etiquette.
* Maintain a living style guide (Storybook or `styleguide_rails`).
* Require green CI and at least one peer approval before merge.
