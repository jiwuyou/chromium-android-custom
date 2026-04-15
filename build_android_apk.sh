#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="/root/chromium-android"
SRC_DIR="$ROOT_DIR/src"
OUT_DIR="${1:-out/Default}"
APK_TARGET="${2:-chrome_public_apk}"

export PATH="$ROOT_DIR/depot_tools:$PATH"
export ALL_PROXY="socks5h://127.0.0.1:1080"
export HTTP_PROXY="$ALL_PROXY"
export HTTPS_PROXY="$ALL_PROXY"
export NO_AUTH_BOTO_CONFIG="/dev/null"
export DEPOT_TOOLS_METRICS=0
export DEPOT_TOOLS_UPDATE=0
export GCLIENT_SUPPRESS_GIT_VERSION_WARNING=1
export CHROMIUM_OUTPUT_DIR="$OUT_DIR"

cd "$SRC_DIR"

# Reuse the already-working outer depot_tools gsutil bootstrap and proxy patch.
cp "$ROOT_DIR/depot_tools/gsutil.py" third_party/depot_tools/gsutil.py
mkdir -p third_party/depot_tools/external_bin/gsutil
cp -a "$ROOT_DIR/depot_tools/external_bin/gsutil/." third_party/depot_tools/external_bin/gsutil/

# Some hooks invoke the vendored depot_tools wrappers directly.
# Bootstrap that copy so python-bin/python3 is available.
(cd third_party/depot_tools && ./ensure_bootstrap)

# DevTools frontend also expects a local depot_tools checkout in its own tree.
mkdir -p third_party/devtools-frontend/src/third_party/depot_tools
cp -a third_party/depot_tools/. third_party/devtools-frontend/src/third_party/depot_tools/
(cd third_party/devtools-frontend/src/third_party/depot_tools && ./ensure_bootstrap)

# Some hooks and wrappers resolve depot_tools from PATH; prefer the in-checkout
# bootstrapped copies so they do not fall back to an uninitialized wrapper.
export PATH="$SRC_DIR/third_party/devtools-frontend/src/third_party/depot_tools:$SRC_DIR/third_party/depot_tools:$ROOT_DIR/depot_tools:$PATH"

gclient runhooks

gn gen "$OUT_DIR" --args='
target_os = "android"
target_cpu = "arm64"
is_component_build = false
is_debug = false
use_remoteexec = false
android_static_analysis = "off"
symbol_level = 0
'

autoninja -C "$OUT_DIR" "$APK_TARGET"

echo
echo "Build finished."
echo "APK target: $APK_TARGET"
echo "Expected APK: $SRC_DIR/$OUT_DIR/apks/ChromePublic.apk"
