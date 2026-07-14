# 🏗 App Builder Bot

A Telegram bot, written in **Go**, that lets anyone build a **real, installable Android app (APK)** by describing it in plain language — no coding required.

The user describes what they want; the bot uses an LLM to design and generate a Flutter app, pushes it to a GitHub repository, builds it with GitHub Actions, waits for the build to go green (auto-fixing build failures with the LLM), and delivers the finished `.apk` file straight back in the chat.

Interface languages: **Тоҷикӣ 🇹🇯 · Русский 🇷🇺 · English 🇬🇧**

---

## ✨ Features

| Feature | What it does |
|---|---|
| 🏗 **App Builder** | Ask for an app name → logo (optional) → a free-text description. A **design model** first produces a UI spec (colors, spacing, elevation, typography, icon tone), then a **coder model** writes a complete Flutter `lib/main.dart` following it. Produces a full multi-screen **MVP** with bottom navigation; when the description resembles a well-known app category (social feed, short-video, editor, chat, shop), it scaffolds that category's standard screens — as a **generic** app under the user's own name, never reproducing a real brand's name, logo, or trade dress. |
| ➕ **Add a function** | Add one new feature to an existing app (e.g. "chat", "map", "currency exchange") without regenerating everything else. |
| 📥 **Import my code** | Bring your own project — as a **ZIP** (≤20 MB) or a **public GitHub repo link** — and the bot commits it to your repo and builds it. A build workflow auto-detects **Flutter** or **Android/Gradle** projects and produces the APK. |
| 📦 **Fetch APK** | Downloads the latest built `.apk` artifact from GitHub Actions and sends it as a Telegram document. |
| ✏️ **Edit app** | Change the description, display name, or logo of an existing app — each edit touches only what changed. |
| 🔁 **Transfer to your GitHub** | Transfer the app's repository to the user's own GitHub account (via GitHub's Transfer API, with recipient confirmation). |
| 🧮 **Price Calculator** | Estimates a price for larger custom projects (screens × functions × package) and forwards the order to the admin. |
| 🎁 **Referrals** | Everyone gets a full multi-screen MVP; free use has a daily limit. Invite 5 subscribed users to **remove the daily limit** (unlimited usage). |
| 🤖 **Chat with AI** | A general conversational assistant (separate from the code generator): the user types anything and the AI replies in their language. |
| 💬 **Contact Admin** | Two-way relay: user messages reach the admin, admin replies are relayed back. |
| ⚙️ **Settings / Help** | Language switch and an in-bot guide. |

### Design & code quality of generated apps

- **Two-stage generation** — a dedicated *design* pass feeds a UI spec into the *coding* pass, so screens look intentional, not generic.
- **Feather icons** — generated apps use the [`flutter_feather_icons`](https://pub.dev/packages/flutter_feather_icons) set (the same outline icon family as `react-icons/fi`).
- **Real functionality, not just mockups** — where a feature can genuinely work with local state or a **keyless public API**, the LLM implements it for real (with `http`, async/await, loading + error states). Features that truly need a backend/auth/paid API stay as clearly-labelled placeholders.
- **Self-healing builds** — if a build fails, the failing job log is fed back to the LLM, which fixes the code, and the build is retried automatically before reporting to the user.

---

## 🏛 Architecture

```
telegram_bot/
├── main.go                    # Entry point, webhook/long-poll setup, update router
├── Dockerfile                 # Multi-stage build → tiny static binary
├── backend/
│   ├── config/                # Env-var loading (config.go, env.go)
│   ├── handlers/              # One file per feature (appbuilder, pricecalc,
│   │                          #   referral, feedback, ratelimit, subscription, …)
│   ├── api/                    # External clients & core logic:
│   │                          #   aicoder.go     – OpenRouter LLM (design + code + fix)
│   │                          #   githubapp.go   – GitHub REST: repos, files, Actions, APK
│   │                          #   referralstore.go – durable state (referrals.json on GitHub)
│   │                          #   tajik/russian/english.go – i18n strings
│   ├── keyboard/              # Reply/inline keyboards
│   ├── database/              # SQLite (users, language, per-user repo mapping)
│   └── utils/                 # Logger, cache, HTTP helpers
```

### How an app gets built (end to end)

1. **Collect input** — display name → logo → description (three short steps).
2. **Create/reuse repo** — one deterministic repo per user (`app-user-<telegramID>`); reused on every subsequent request so a user never accumulates repos.
3. **Scaffold** — `auto-create.yml` runs `flutter create`, sets the app label, injects the `INTERNET` permission (needed for release builds), applies the logo via `flutter_launcher_icons`, and commits the project back to the repo.
4. **Generate** — the LLM writes `lib/main.dart` (design pass → code pass) and it is pushed to the repo.
5. **Build** — `build.yml` runs `flutter build apk --release` and uploads the APK artifact.
6. **Wait & auto-fix** — the bot polls the workflow run; on failure it feeds the log back to the LLM, pushes a fix, and retries.
7. **Deliver** — on success, the user taps **Fetch APK** and receives the file.

### Durable state

Render's disk is ephemeral (wiped on redeploy), so anything that must survive a deploy is **not** trusted to local SQLite:
- **Per-user repo naming** is deterministic (`app-user-<id>`), so GitHub itself is the source of truth.
- **Referral counts** are stored as `referrals.json` in a dedicated private GitHub repo (`appbuilder-bot-state`).

### Reliability details worth noting

- **Webhook, not long-polling**, in production — Render's zero-downtime deploys run two instances briefly, which breaks `getUpdates` with a Telegram *Conflict*; webhooks avoid this.
- **Model fallback** — free OpenRouter models rotate/rate-limit often, so requests fall through a list of models and finally the `openrouter/free` auto-router, honoring `retry_after_seconds`.
- **AI usage rate limiting** — a generous free allowance per user, then a cooldown that scales with overuse.

---

## 🚀 Running it

### Prerequisites

- Go 1.21+
- A Telegram bot token from [@BotFather](https://t.me/BotFather)
- A **classic** GitHub Personal Access Token with the `repo` scope (the App Builder feature needs it to create repos and trigger Actions)
- An [OpenRouter](https://openrouter.ai) API key (free tier works)

### Local

```bash
cp .env.example .env      # then fill in the values
go mod tidy
go run .
```

### Docker

```bash
docker build -t appbuilder-bot .
docker run --env-file .env -p 10000:10000 appbuilder-bot
```

### Render (production)

Deploy as a Web Service from this repo (Render auto-detects the `Dockerfile`), set the environment variables below, and Render's `RENDER_EXTERNAL_URL` enables webhook mode automatically.

---

## 🔧 Environment variables

| Variable | Required | Purpose |
|---|:--:|---|
| `TELEGRAM_BOT_TOKEN` | ✅ | Bot token from BotFather |
| `GITHUB_APP_BUILDER_TOKEN` | ✅ | Classic PAT (`repo` scope) — builds & delivers APKs |
| `OPENROUTER_API_KEY` | ✅ | LLM access for design + code generation |
| `OPENROUTER_MODEL` | — | Override the default primary model |
| `ADMIN_CHAT_ID` | — | Telegram ID that receives "Contact Admin" messages & orders (send `/myid` to the bot to find yours) |
| `REQUIRED_CHANNELS` | — | Comma-separated `@channels` users must join before use (sponsor gate) |
| `SPONSOR_ENABLED` | — | Master switch for the sponsor gate (default off); set `true` to enforce `REQUIRED_CHANNELS` |
| `DEFAULT_LANGUAGE` | — | `fa` (default), `ru`, or `en` |
| `DB_PATH` | — | SQLite path (default `./data/appbuilder.db`) |
| `PORT` | — | HTTP port (default `10000`) |

---

## 🧩 Commands

| Command | Description |
|---|---|
| `/start` | Start / choose language (supports `?start=ref_<id>` referral links) |
| `/settings` | Change interface language |
| `/help` | Show the in-bot guide |
| `/myid` | Show your Telegram ID (for setting `ADMIN_CHAT_ID`) |

---

## 📝 Notes

- Generated APKs are **release** builds signed with the debug keystore — installable immediately, no signing setup required.
- Telegram bots can upload files up to ~50 MB; the bot guards against oversized APKs and reports clearly instead of failing silently.
