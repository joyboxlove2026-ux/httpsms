# Working in this repository

httpSMS: a Go API (`api/`) plus a Nuxt web UI (`web/`) that turn an Android phone into an SMS gateway.

## Sandbox / dev environment

Use the Base44 sandbox stack, not the project's own compose file:

```bash
docker compose -f docker-compose.base44.yml up -d      # start everything
docker compose -f docker-compose.base44.yml ps -a      # api, web, postgres, redis, seed
docker compose -f docker-compose.base44.yml logs -f web
```

- `web` -> http://localhost:3000 (Nuxt dev server, `pnpm dev`, live reload)
- `api` -> http://localhost:8000 (Go API; Swagger UI at http://localhost:8000/index.html)

`docker-compose.yml` (the project's own file) is NOT used here: it builds production images from
`api/Dockerfile` and `web/Dockerfile` that bake the source in, so edits would never show up.
The sandbox stack runs plain runtime images (`golang:1.26-alpine`, `node:22`, `postgres:16`, `redis:7`)
with the source bind-mounted, dependencies installed at container start, and dev servers running.

### Things that are easy to get wrong

- **The API refuses to boot without `FIREBASE_CREDENTIALS`.** `container.App()` builds the bearer-token
  middleware, which initialises the Firebase Admin SDK and calls `logger.Fatal` on error. It must be
  parseable service-account JSON with a valid RSA key, so a random opaque placeholder will *not* work.
  `base44/api-entrypoint.sh` generates a throwaway service account (valid RSA key, no privileges) when
  the variable is empty; a real value from `/run/base44/app.env` takes precedence. FCM notifications are
  not delivered while the placeholder is in use.
- **Live reload needs the `--dotenv=false` argument.** `api/main.go` calls `di.LoadEnv()` (godotenv) when
  it gets no argument, and that calls `log.Fatal` if `api/.env` is missing. `air` starts the binary with
  the argument, so nothing has to be created in the repo.
- **First `api` start is slow** (a few minutes): it downloads the Go module cache and builds everything.
  Go module/build caches live in named volumes, so later starts are fast.
- **PostgreSQL, not CockroachDB.** GORM `AutoMigrate` creates the schema on API start, which is why the
  `seed` service depends on `api: service_healthy` and then inserts the system user documented in the
  README (`EVENTS_QUEUE_USER_ID` / `EVENTS_QUEUE_USER_API_KEY` in `base44.defaults.env`).
- **MongoDB is not needed.** `CONTACT_DB_BACKEND` / `HEARTBEAT_DB_BACKEND` default to the GORM backends;
  only the integration test stack sets them to `mongodb`.
- **`web/node_modules` lives in a named volume**, while `pnpm install --frozen-lockfile` runs on every
  start (fast when up to date). `HUSKY=0` disables the `prepare` git-hook script, which is pointless in
  the sandbox.
- **The browser reaches the API on its own public port** (`API_BASE_URL=https://8000-$BASE44_PUBLIC_HOST_SUFFIX`),
  and the API's CORS defaults (`*` without credentials) allow it. Auth uses a bearer token, not cookies.
- Health checks use `127.0.0.1`, not `localhost`: the API listens on IPv4 only and `localhost` can
  resolve to `::1` inside the container (busybox `wget` fails with "Connection refused").
- `401 Unauthorized ... axiom.co` lines in the API logs are expected: Axiom telemetry needs `AXIOM_TOKEN`.

### Verifying it works

```bash
curl -s -o /dev/null -w '%{http_code}\n' http://localhost:3000/          # 200 from the Nuxt UI
curl -s -o /dev/null -w '%{http_code}\n' http://localhost:8000/health    # 200 from the API
docker compose -f docker-compose.base44.yml exec -T postgres \
  psql -U dbusername -d httpsms -c 'select id, email from users;'        # system user is seeded
```

## Credentials

Secrets are delivered by the platform to `/run/base44/app.env` (outside the repository) and are listed
last in `env_file:` so user-supplied values always beat the placeholders in `base44.defaults.env`.
`base44.defaults.env` itself contains no real credentials.

Without Firebase web config the site renders but the login page cannot authenticate, and without real
`FIREBASE_CREDENTIALS` no push notification reaches an Android phone.
