#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

usage() {
  cat <<'USAGE'
Usage:
  scripts/build_release.sh <env> [export_options_plist]

Examples:
  scripts/build_release.sh prod
  scripts/build_release.sh prod ios/ExportOptions.plist

Behavior:
  1) Increments pubspec.yaml build number once
  2) Builds IPA sequentially with that build number
  3) Builds AAB sequentially with the same build number
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

ENV_INPUT="${1:-}"
EXPORT_OPTIONS_PLIST="${2:-}"

if [[ -z "$ENV_INPUT" ]]; then
  read -r -p "Environment (prod): " ENV_INPUT
fi

ENV_INPUT="$(echo "$ENV_INPUT" | tr '[:upper:]' '[:lower:]')"

VERSION_LINE="$(awk '/^version:/ {print $2; exit}' pubspec.yaml)"
if [[ -z "$VERSION_LINE" ]]; then
  echo "[ERROR] Could not find version in pubspec.yaml"
  exit 1
fi

BUILD_NAME="${VERSION_LINE%%+*}"
OLD_BUILD_NUMBER="${VERSION_LINE##*+}"

if ! [[ "$OLD_BUILD_NUMBER" =~ ^[0-9]+$ ]]; then
  echo "[ERROR] Build number is not numeric in pubspec.yaml: $VERSION_LINE"
  exit 1
fi

NEW_BUILD_NUMBER=$((OLD_BUILD_NUMBER + 1))
NEW_VERSION="${BUILD_NAME}+${NEW_BUILD_NUMBER}"

awk -v new_version="$NEW_VERSION" '
BEGIN { replaced = 0 }
{
  if (!replaced && $1 == "version:") {
    print "version: " new_version
    replaced = 1
  } else {
    print $0
  }
}
END {
  if (!replaced) {
    exit 2
  }
}
' pubspec.yaml > pubspec.yaml.tmp && mv pubspec.yaml.tmp pubspec.yaml

echo "[INFO] pubspec version bumped once for release build: ${VERSION_LINE} -> ${NEW_VERSION}"

ipa_cmd=(
  env
  SKIP_VERSION_BUMP=1
  "$ROOT_DIR/scripts/build_ipa.sh"
  "$ENV_INPUT"
)

if [[ -n "$EXPORT_OPTIONS_PLIST" ]]; then
  ipa_cmd+=("$EXPORT_OPTIONS_PLIST")
fi

aab_cmd=(
  env
  SKIP_VERSION_BUMP=1
  "$ROOT_DIR/scripts/build_aab.sh"
  "$ENV_INPUT"
)

echo "[INFO] Starting sequential mobile release build for ${ENV_INPUT}"
printf '[INFO] IPA command: %q ' "${ipa_cmd[@]}"
echo
"${ipa_cmd[@]}"

printf '[INFO] AAB command: %q ' "${aab_cmd[@]}"
echo
"${aab_cmd[@]}"

echo "[DONE] Release build complete for ${ENV_INPUT} (${NEW_VERSION})"
