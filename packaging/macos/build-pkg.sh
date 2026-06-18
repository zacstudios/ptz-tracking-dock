#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 || $# -gt 3 ]]; then
  echo "Usage: $0 <ptz-tracking-dock.plugin> <output.pkg> [version]" >&2
  exit 2
fi

BUNDLE_PATH="$1"
OUTPUT_PKG="$2"
VERSION="${3:-0.1.0}"
export COPYFILE_DISABLE=1

if [[ ! -d "$BUNDLE_PATH" ]]; then
  echo "Plugin bundle not found: $BUNDLE_PATH" >&2
  exit 1
fi

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

PAYLOAD_ROOT="$WORK_DIR/payload"
mkdir -p "$PAYLOAD_ROOT"

STAGING_DIR="$PAYLOAD_ROOT/Library/Application Support/ptz-tracking-dock"
mkdir -p "$STAGING_DIR"

BUNDLE_COPY="$STAGING_DIR/ptz-tracking-dock.plugin"
/bin/cp -R "$BUNDLE_PATH" "$BUNDLE_COPY"
/usr/bin/find "$BUNDLE_COPY" \( -name '.DS_Store' -o -name '._*' \) -delete
/usr/bin/dot_clean -m "$BUNDLE_COPY" 2>/dev/null || true
/usr/bin/xattr -cr "$BUNDLE_COPY" 2>/dev/null || true

COMPONENT_PLIST="$WORK_DIR/components.plist"
COPYFILE_DISABLE=1 /usr/bin/pkgbuild \
  --analyze \
  --root "$PAYLOAD_ROOT" \
  "$COMPONENT_PLIST"

/usr/libexec/PlistBuddy -c "Add :0:BundleIsRelocatable bool false" "$COMPONENT_PLIST"
/usr/libexec/PlistBuddy -c "Set :0:BundleOverwriteAction upgrade" "$COMPONENT_PLIST"

COPYFILE_DISABLE=1 /usr/bin/pkgbuild \
  --root "$PAYLOAD_ROOT" \
  --component-plist "$COMPONENT_PLIST" \
  --scripts "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts" \
  --identifier "com.tallyhubpro.ptz-tracking-dock" \
  --version "$VERSION" \
  --install-location "/" \
  "$OUTPUT_PKG"
