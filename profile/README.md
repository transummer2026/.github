# Transummer 2026

We are a team of five 42 students building **[Pollpear](https://github.com/transummer2026/Pollpear)**,
a real-time collaborative polling platform — our `ft_transcendence`, the final web project
of the 42 common core.

## Pollpear

People meet in shared **rooms** where they create polls, vote, and discuss in a live chat.
Every vote, message, presence change and notification propagates to all participants over
WebSockets, with catch-up after a network drop — no page reload, anywhere.

Beyond the polls themselves: several poll types (single and multiple choice, slider, free
field), anonymous or attributed voting, hashtags, templates, and **poll dependencies** —
a poll unlocked by a specific answer to a previous one. Around them sit a social graph
(friendships, blocking, reporting), an ML-ranked personalized feed, OAuth 2.0 sign-in,
role- and ownership-based authorization, and a key-authenticated public REST API.

## Architecture

A **polyglot microservice** stack: an nginx edge with a ModSecurity WAF fronts a React
SPA, a Rust API gateway, a NestJS backend and a Python ML service — backed by PostgreSQL,
Redis, Garage object storage and HashiCorp Vault, with Prometheus and Grafana watching it
all.

| Repository | What it is |
| :--- | :--- |
| [`Pollpear`](https://github.com/transummer2026/Pollpear) | Superproject — Docker Compose orchestration, Makefile, every service as a submodule |
| [`Pollpear_frontend`](https://github.com/transummer2026/Pollpear_frontend) | React 19 · TypeScript · Vite · Tailwind 4 · shadcn/ui · SWR · Socket.IO |
| [`Pollpear_backend`](https://github.com/transummer2026/Pollpear_backend) | NestJS 11 · Prisma 7 · CASL · Passport · Argon2 · Socket.IO — 30+ domain modules |
| [`Pollpear_gateway`](https://github.com/transummer2026/Pollpear_gateway) | Rust · axum — the `/api` edge: sessions, API keys, rate limiting, WS proxying |
| [`Pollpear_ai`](https://github.com/transummer2026/Pollpear_ai) | Python 3.14 · FastAPI · scikit-learn — the feed recommendation model |
| [`Pollpear_shared`](https://github.com/transummer2026/Pollpear_shared) | Zod schemas generated from the Prisma schema, shared across services |
| [`Pollpear_infra`](https://github.com/transummer2026/Pollpear_infra) | nginx + WAF, Vault, PostgreSQL, Redis, Garage, Prometheus/Grafana |
| [`Pollpear_cyber`](https://github.com/transummer2026/Pollpear_cyber) | Application secrets and the Vault migration tooling |

**Why these choices.** A relational schema with real constraints fits a domain full of
well-defined relations better than a document store. A Rust gateway concentrates the
cross-cutting concerns — auth, rate limiting, API keys, WebSocket proxying — in one fast,
memory-safe edge. The ML model stays in the Python ecosystem built for it, off the request
path. Secrets live in Vault, never in an image. And one set of Zod schemas, generated from
the Prisma schema, keeps validation honest across every service.

## The team

| | Role |
| :--- | :--- |
| [@blucken](https://github.com/blucken) | Security Engineer |
| [@Hyliah](https://github.com/Hyliah) | Product Owner |
| [@jrandetdev](https://github.com/jrandetdev) | Project Manager |
| [@pieric-ux](https://github.com/pieric-ux) | Tech Lead |
| [@RaphyStoll](https://github.com/RaphyStoll) | DevOps Engineer |

Setup instructions, the database schema and the full module breakdown live in the
[main repository's README](https://github.com/transummer2026/Pollpear#readme).
