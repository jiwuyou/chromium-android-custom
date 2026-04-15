# Chromium Android Custom Build

This repository tracks the custom Android browser build workflow used on top of a local Chromium checkout.

## Baseline

- Chromium revision: `a83129ac6d`
- Local working branch: `custom/android-browser`
- Android target: `chrome_public_apk`
- Output APK: `src/out/Default/apks/ChromePublic.apk`

## Layout

- `build_android_apk.sh`: helper script used to build the Android APK from the local Chromium tree

## Notes

This repository intentionally does not vendor the full Chromium source tree.
The upstream source checkout is large and should be managed separately with `fetch`, `gclient`, and local branches for custom changes.

Recommended workflow:

1. Sync Chromium upstream in a local checkout.
2. Create or update a custom branch.
3. Keep customizations as a small patch set.
4. Rebuild with `build_android_apk.sh`.

## Current Result

- The APK was built successfully from the local checkout.
- Package name: `org.chromium.chrome`
- Version name: `149.0.7788.0`

