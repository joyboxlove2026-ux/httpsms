#!/bin/sh
# Sandbox entrypoint for the httpSMS API (used only by docker-compose.base44.yml).
#
# It does not change application behaviour. It exists so the API can boot in
# the preview without the external credentials a real deployment needs:
#
#   * FIREBASE_CREDENTIALS: when it is empty a throwaway service account is
#     generated (the same approach as tests/generate-firebase-credentials.sh)
#     so the Firebase Admin SDK initialises. The key is unprivileged and can
#     never deliver push notifications; supply a real service account to make
#     FCM work. A value from the Base44 dashboard (/run/base44/app.env) is
#     used as-is, the generated placeholder only fills the gap.
#   * Live reload: the API runs under `air` so Go edits are picked up without
#     rebuilding the container. `air` is installed on first start and falls
#     back to `go run` if it cannot be fetched.
set -e

if [ -z "${FIREBASE_CREDENTIALS:-}" ]; then
  echo "[base44] FIREBASE_CREDENTIALS is empty: generating a throwaway Firebase service account."
  if ! command -v openssl >/dev/null 2>&1; then
    apk add --no-cache openssl >/dev/null 2>&1 || true
  fi
  PRIVATE_KEY=$(openssl genrsa 2048 2>/dev/null)
  PRIVATE_KEY_ESCAPED=$(printf '%s\n' "$PRIVATE_KEY" | awk '{printf "%s\\n", $0}')
  FIREBASE_CREDENTIALS=$(cat <<JSON
{
  "type": "service_account",
  "project_id": "${GCP_PROJECT_ID:-httpsms-local}",
  "private_key_id": "base44-dev-key-id",
  "private_key": "${PRIVATE_KEY_ESCAPED}",
  "client_email": "base44-dev@${GCP_PROJECT_ID:-httpsms-local}.iam.gserviceaccount.com",
  "client_id": "000000000000000000000",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/base44-dev"
}
JSON
)
  export FIREBASE_CREDENTIALS
fi

cd /app

echo "[base44] downloading Go modules"
go mod download

if ! command -v air >/dev/null 2>&1; then
  echo "[base44] installing air (live reload)"
  GOBIN=/usr/local/bin go install github.com/air-verse/air@latest >/dev/null 2>&1 || true
fi

if command -v air >/dev/null 2>&1; then
  exec air -c /app/.air.toml
fi

echo "[base44] air is unavailable, running the API without live reload"
exec go run . --dotenv=false
