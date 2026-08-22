#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

usage() {
  cat <<'USAGE'
Usage:
  scripts/build_aab.sh <env>

Examples:
  scripts/build_aab.sh prod

Behavior:
  1) Increments pubspec.yaml build number (x.y.z+N -> x.y.z+(N+1))
     unless SKIP_VERSION_BUMP=1 is set
  2) Builds AAB from lib/main.dart (RecoveryFit has a single entrypoint,
     no per-environment flavors)
  3) Copies the output bundle to a versioned filename
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

ENV_INPUT="${1:-}"

if [[ -z "$ENV_INPUT" ]]; then
  read -r -p "Environment (prod): " ENV_INPUT
fi

ENV_INPUT="$(echo "$ENV_INPUT" | tr '[:upper:]' '[:lower:]')"

ensure_java_runtime() {
  local candidate
  local -a java_home_candidates=(
    "${JAVA_HOME:-}"
    "/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
    "/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home"
    "/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
    "/Applications/Android Studio.app/Contents/jbr/Contents/Home"
    "/Applications/Android Studio.app/Contents/jre/Contents/Home"
  )

  if command -v java >/dev/null 2>&1 && java -version >/dev/null 2>&1; then
    return 0
  fi

  if [[ -x /usr/libexec/java_home ]]; then
    candidate="$(/usr/libexec/java_home 2>/dev/null || true)"
    if [[ -n "$candidate" && -x "$candidate/bin/java" ]]; then
      export JAVA_HOME="$candidate"
      export PATH="$JAVA_HOME/bin:$PATH"
      return 0
    fi
  fi

  for candidate in "${java_home_candidates[@]}"; do
    if [[ -n "$candidate" && -x "$candidate/bin/java" ]]; then
      export JAVA_HOME="$candidate"
      export PATH="$JAVA_HOME/bin:$PATH"
      return 0
    fi
  done

  if compgen -G "/Library/Java/JavaVirtualMachines/*/Contents/Home" >/dev/null; then
    for candidate in /Library/Java/JavaVirtualMachines/*/Contents/Home; do
      if [[ -x "$candidate/bin/java" ]]; then
        export JAVA_HOME="$candidate"
        export PATH="$JAVA_HOME/bin:$PATH"
        return 0
      fi
    done
  fi

  echo "[ERROR] Unable to locate a Java runtime for Android builds."
  echo "[ERROR] Install a JDK or set JAVA_HOME before running this script."
  exit 1
}

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

ensure_java_runtime

echo "[INFO] Running flutter pub get"
flutter pub get

cmd=(
  flutter build appbundle
  --release
  --target lib/main.dart
  --build-name "$BUILD_NAME"
  --build-number "$BUILD_NUMBER_TO_USE"
)

echo "[INFO] Building AAB for env=$ENV_INPUT build=${BUILD_NAME}+${BUILD_NUMBER_TO_USE}"
printf '[INFO] Command: %q ' "${cmd[@]}"
echo

"${cmd[@]}"

AAB_DIR="build/app/outputs/bundle/release"
AAB_SOURCE="${AAB_DIR}/app-release.aab"
AAB_OUTPUT="${AAB_DIR}/app-${ENV_INPUT}-${BUILD_NAME}+${BUILD_NUMBER_TO_USE}.aab"

if [[ -f "$AAB_SOURCE" ]]; then
  cp -f "$AAB_SOURCE" "$AAB_OUTPUT"
  echo "[INFO] AAB copied: $AAB_OUTPUT"
else
  echo "[WARN] app-release.aab not found at ${AAB_SOURCE}. Check build output manually."
fi

echo "[DONE] Build complete for ${ENV_INPUT} (${BUILD_NAME}+${BUILD_NUMBER_TO_USE})"
