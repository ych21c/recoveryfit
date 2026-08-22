#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

usage() {
  cat <<'USAGE'
Usage:
  scripts/build_ipa.sh <env> [export_options_plist]

Examples:
  scripts/build_ipa.sh prod
  scripts/build_ipa.sh prod ios/ExportOptions.plist

Behavior:
  1) Increments pubspec.yaml build number (x.y.z+N -> x.y.z+(N+1))
     unless SKIP_VERSION_BUMP=1 is set
  2) Builds IPA from lib/main.dart (RecoveryFit has a single entrypoint,
     no per-environment flavors)
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

BUILD_NUMBER_TO_USE="$OLD_BUILD_NUMBER"

if [[ "${SKIP_VERSION_BUMP:-0}" == "1" ]]; then
  echo "[INFO] Using existing pubspec version without bump: ${VERSION_LINE}"
else
  BUILD_NUMBER_TO_USE=$((OLD_BUILD_NUMBER + 1))
  NEW_VERSION="${BUILD_NAME}+${BUILD_NUMBER_TO_USE}"

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

  echo "[INFO] pubspec version bumped: ${VERSION_LINE} -> ${NEW_VERSION}"
fi

echo "[INFO] Running flutter pub get"
flutter pub get

cmd=(
  flutter build ipa
  --release
  --target lib/main.dart
  --build-name "$BUILD_NAME"
  --build-number "$BUILD_NUMBER_TO_USE"
)

if [[ -n "$EXPORT_OPTIONS_PLIST" ]]; then
  cmd+=(--export-options-plist "$EXPORT_OPTIONS_PLIST")
fi

echo "[INFO] Building IPA for env=$ENV_INPUT build=${BUILD_NAME}+${BUILD_NUMBER_TO_USE}"
printf '[INFO] Command: %q ' "${cmd[@]}"
echo

"${cmd[@]}"

IPA_DIR="build/ios/ipa"
IPA_SOURCE="${IPA_DIR}/Runner.ipa"
IPA_OUTPUT="${IPA_DIR}/Runner-${ENV_INPUT}-${BUILD_NAME}+${BUILD_NUMBER_TO_USE}.ipa"

if [[ -f "$IPA_SOURCE" ]]; then
  cp -f "$IPA_SOURCE" "$IPA_OUTPUT"
  echo "[INFO] IPA copied: $IPA_OUTPUT"
else
  echo "[WARN] Runner.ipa not found at ${IPA_SOURCE}. Check build output manually."
fi

echo "[DONE] Build complete for ${ENV_INPUT} (${BUILD_NAME}+${BUILD_NUMBER_TO_USE})"
