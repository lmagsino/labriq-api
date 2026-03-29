# Labriq API

> AI-first backend for the Labriq mobile app — built with Rails 7.1, powered by Claude AI, and developed with Claude Code.

Labriq is an AI-enabled lab results interpreter: users upload their lab results and get a plain-language summary, flagged values, and a doctor-prep card with smart questions — in seconds. Think "Shazam for lab results."

This repo is the Rails API backend that handles authentication, file uploads, AI analysis via Claude, and serves results to the Expo mobile app (`labriq-app`).

---

## Stack

| Layer | Technology |
|---|---|
| Framework | Ruby on Rails 7.1 (API mode) |
| Ruby | 3.2+ |
| Database | PostgreSQL 15+ |
| Background Jobs | Sidekiq |
| Cache / Queue | Redis 7+ |
| File Storage | Active Storage + S3/R2 |
| AI | Claude Sonnet (Anthropic API) |
| Auth | Devise + devise-jwt |
| Testing | RSpec + FactoryBot |

---

## Getting Started

### Prerequisites

- Ruby 3.2+
- PostgreSQL 15+
- Redis 7+

### Setup

```bash
git clone https://github.com/your-org/labriq-api.git
cd labriq-api
bundle install
cp .env.example .env   # fill in your secrets
rails db:create db:migrate db:seed
```

### Environment Variables

Copy `.env.example` and fill in:

```
DATABASE_URL=postgres://localhost/labriq_api_development
REDIS_URL=redis://localhost:6379/0
ANTHROPIC_API_KEY=sk-ant-xxxxx
DEVISE_JWT_SECRET_KEY=   # generate with: rails secret
```

---

## Running Locally

Start the API server and background worker in separate terminals:

```bash
bundle exec rails server          # API on http://localhost:3000
bundle exec sidekiq               # Background job worker
```

Or use the Procfile:

```bash
foreman start
```

Health check: `GET /health`

---

## Running Tests

```bash
bundle exec rspec
```

---

## API Overview

All endpoints are under `/api/v1/`. JWT is returned in the `Authorization` response header on login/register.

### Auth

| Method | Endpoint | Auth Required |
|---|---|---|
| POST | `/api/v1/auth/register` | No |
| POST | `/api/v1/auth/login` | No |
| DELETE | `/api/v1/auth/logout` | Yes |

### Scans

| Method | Endpoint | Auth Required |
|---|---|---|
| POST | `/api/v1/scans` | Optional |
| GET | `/api/v1/scans/:id` | Optional |
| GET | `/api/v1/scans` | Yes |

File upload via `multipart/form-data`: `lab_files[]` and optionally `prescription_files[]`.

### Other

| Method | Endpoint | Auth Required |
|---|---|---|
| POST | `/api/v1/feedback` | No |
| GET | `/api/v1/share/:token` | No |
| GET | `/health` | No |

---

## How the AI Analysis Works

1. User uploads lab result files (PDF or image)
2. API creates a `Scan` record and immediately returns the scan ID
3. `AnalyzeScanJob` runs asynchronously via Sidekiq:
   - Sends files to Claude (Anthropic API) as base64-encoded content blocks
   - Claude extracts values, flags abnormals, writes plain-language explanations, and generates doctor questions
   - Results are saved as `LabResult` and `DoctorQuestion` records
4. Uploaded files are purged after processing
5. Client polls `GET /api/v1/scans/:id` until `status: "completed"`

The AI prompt is stored in the `PromptTemplate` model and can be updated without a deploy.

---

## Project Structure

```
app/
  controllers/api/v1/   # Versioned API controllers
  models/               # AR models
  services/             # claude_service.rb — core AI logic
  jobs/                 # analyze_scan_job.rb, cleanup_scan_files_job.rb
  serializers/          # JSONAPI serializers
  middleware/           # Redis-based rate limiter
config/
  initializers/         # cors.rb, devise.rb, sidekiq.rb
db/
  seeds.rb              # Seeds default AI prompt template
spec/                   # RSpec — models, requests, services, jobs
```

---

## AI Disclosure

This project is **AI-first by design** — the core product feature is powered by the Anthropic Claude API. The backend was also built with the assistance of **[Claude Code](https://claude.ai/code)**, Anthropic's AI coding tool, across all phases of development including models, controllers, services, jobs, and specs.
