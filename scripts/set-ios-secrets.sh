#!/usr/bin/env bash
# Put the seven repository secrets the TestFlight workflow needs into GitHub.
#
# Five of them come from ~/keystores and are shared across her whole Apple
# account — this reads them off disk so nothing is retyped and nothing is
# pasted into a chat window. Two cannot be: the App Store Connect issuer id,
# which exists only in App Store Connect, and the Astrolabe provisioning
# profile, which has to be created first.
#
# ⚠ Safe to re-run. Setting a secret replaces it.
set -euo pipefail

REPO=${REPO:-ShrutiVtuber/shruti-tools}
KEYS=${KEYS:-$HOME/keystores}
APP=$(cd "$(dirname "$0")/.." && pwd)

need() { [ -f "$1" ] || { echo "missing: $1"; exit 1; }; }

echo "Setting secrets on $REPO"
echo

# ── shared across the account ───────────────────────────────────────────────
need "$KEYS/AuthKey_32VS9C8RF8.p8"
need "$KEYS/theourgia-ios-dist.p12"
need "$KEYS/theourgia-ios-dist-p12-password.txt"

gh secret set ASC_KEY_ID --repo "$REPO" --body "32VS9C8RF8"
echo "  ASC_KEY_ID"

gh secret set ASC_KEY_P8 --repo "$REPO" < "$KEYS/AuthKey_32VS9C8RF8.p8"
echo "  ASC_KEY_P8"

# ⚠ base64 -w0: without it the encoder wraps at 76 columns and the secret
# arrives with newlines in it, which `base64 -d` on the runner survives but
# some shells do not.
base64 -w0 "$KEYS/theourgia-ios-dist.p12" | gh secret set IOS_DIST_P12 --repo "$REPO"
echo "  IOS_DIST_P12          (the account-wide distribution certificate)"

gh secret set IOS_DIST_P12_PASSWORD --repo "$REPO" < "$KEYS/theourgia-ios-dist-p12-password.txt"
echo "  IOS_DIST_P12_PASSWORD"

# ── this app's Firebase config, for the Linux gate's Android build ──────────
need "$APP/android/app/google-services.json"
base64 -w0 "$APP/android/app/google-services.json" | gh secret set GOOGLE_SERVICES_JSON --repo "$REPO"
echo "  GOOGLE_SERVICES_JSON  (gitignored, so CI has no other copy)"

# ── Astrolabe's own profile, once it exists ────────────────────────────────
PROFILE="$KEYS/astrolabe-appstore.mobileprovision"
if [ -f "$PROFILE" ]; then
  base64 -w0 "$PROFILE" | gh secret set IOS_PROFILE_B64 --repo "$REPO"
  echo "  IOS_PROFILE_B64"
else
  echo
  echo "  ⚠ IOS_PROFILE_B64 not set — $PROFILE does not exist yet."
  echo "    Create the App Store profile named exactly 'Astrolabe' against"
  echo "    com.shrutivtuber.astrolabe and the EXISTING distribution"
  echo "    certificate, save it there, and run this again."
fi

# ── the one value that lives nowhere on this machine ───────────────────────
if [ -n "${ASC_ISSUER_ID:-}" ]; then
  gh secret set ASC_ISSUER_ID --repo "$REPO" --body "$ASC_ISSUER_ID"
  echo "  ASC_ISSUER_ID"
else
  echo
  echo "  ⚠ ASC_ISSUER_ID not set — it exists only in App Store Connect."
  echo "    Users and Access → Integrations → App Store Connect API → Issuer ID"
  echo "    (a UUID above the key list; the same for every app in the account)."
  echo "    Then:  ASC_ISSUER_ID=<the-uuid> $0"
fi

echo
echo "Now set:"
gh secret list --repo "$REPO"
