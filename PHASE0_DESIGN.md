# Phase 0 — Project Setup & Interface Design

Design + research only. No Dart code in this phase (per project rule). This document is
the reference you build Phase 1 from.

Researched against pub.dev on 2026-06-17.

---

## 1. Pinned package versions

Pin **exact** versions (no `^`). The Scanwedge enum names vary by version, so the whole
point is reproducibility — a caret range defeats that.

```yaml
dependencies:
  flutter:
    sdk: flutter
  honeywell_scanner: 8.0.0              # latest, publ. 2025-12-03
  pointmobile_scanner_advanced: 0.0.15  # latest, publ. 2025-07-22
  scanwedge: 1.1.3                      # latest, publ. 2026-03-11
  provider: 6.1.5+1                     # latest, publ. ~2025-10
```

Notes per package:

- **honeywell_scanner 8.0.0** — wraps Honeywell's native *Data Collection SDK*. The `.aar`
  is **not** shipped via pub; it must be dropped into the Android module by hand (see §3).
  Android-only, BSD-3.
- **pointmobile_scanner_advanced 0.0.15** — still `0.0.x`, single maintainer, low download
  count. API is a **static class** (`PMScanner`), not an instantiable object. Bundles a
  `device.sdk.jar`. Android-only, BSD-3.
- **scanwedge 1.1.3** — multi-vendor (Honeywell, Datalogic, Newland, Urovo, Zebra) via
  Android Intent/DataWedge-style profiles. **Unverified uploader.** Apache-2.0. This is the
  one whose enum identifiers drift between releases — pinning 1.1.3 freezes the names in §5.
- **provider 6.1.5+1** — Flutter Favorite, stable. Used for the `ChangeNotifier` in §6.

---

## 2. Android SDK requirements

Pulled from each plugin's `android/build.gradle(.kts)`:

| Package                        | compileSdk | minSdk | Java | Kotlin  | AGP     |
|--------------------------------|-----------:|-------:|-----:|---------|---------|
| honeywell_scanner 8.0.0        | 36         | 19     | 21   | —       | 8.13.1  |
| pointmobile_scanner_advanced 0.0.15 | 34    | 21     | 8    | 1.8.22  | 8.7.3   |
| scanwedge 1.1.3                | 36         | 24     | 17   | 2.2.20  | 8.11.1  |

**Take the highest of each → app-level config:**

```
minSdkVersion    24      // scanwedge floor; drops < Android 7.0 (fine for rugged PDAs)
compileSdkVersion 36     // honeywell + scanwedge
targetSdkVersion  36     // match compileSdk
```

Toolchain (highest wins, because the host app must be able to compile every plugin):

- **JDK 21** — honeywell_scanner compiles with `sourceCompatibility 21`. Building with an
  older JDK fails. Set `JAVA_HOME` to a JDK 21 and use Java 17+ desugaring in the app's
  `compileOptions`.
- **Kotlin 2.2.20+** — scanwedge's floor; safely covers pointmobile's 1.8.22.
- **Android Gradle Plugin 8.13.1+** — honeywell's floor.
- **Gradle wrapper 8.13+** — required by AGP 8.13.

---

## 3. Per-package native setup (flag for Phase 1, not Phase 0)

Two of the three SDKs are vendor-locked binaries that pub cannot resolve:

- **Honeywell:** download `Honeywell_MobilitySDK_Android` from the Honeywell support portal
  (account required), copy the `honeywell` folder (with `DataCollection.aar`) from the
  plugin's `example/android/honeywell` into your android module, add `include ':honeywell'`
  to `settings.gradle`, and add `tools:replace="android:label"` on `<application>` in
  `AndroidManifest.xml` (else manifest merger fails).
- **Point Mobile:** the plugin bundles `device.sdk.jar` itself — usually nothing extra, but
  builds only succeed on/against Point Mobile hardware.
- **Scanwedge:** pure Intent-based, no binary drop-in.

You can `flutter create` and wire the Dart layer without any of this; the native drop-ins
only matter once you build for a real device.

---

## 4. Folder structure

```
lib/
  main.dart
  providers/
    scanner_provider.dart          # ChangeNotifier: active scanner + status + last value + history
  scanners/
    scanner_service.dart           # ScannerService interface + ScanResult + ScannerType + ScannerStatus
    honeywell_scanner_service.dart
    pointmobile_scanner_service.dart
    scanwedge_scanner_service.dart
    scanner_factory.dart           # ScannerType -> ScannerService
  screens/
    scan_screen.dart               # dropdown + last value + history + status + scan button
```

`flutter create` the project Android-only (ignore the `ios/` and `web/` folders it generates).

---

## 5. Core types (confirmed)

```dart
enum ScannerType { honeywell, pointMobile, scanwedge }

enum ScannerStatus { idle, initialising, ready, deviceNotSupported, error }

class ScanResult {
  final String code;
  final String? symbology;   // null when the SDK doesn't provide it
  final DateTime timestamp;
}

abstract class ScannerService {
  void Function(ScanResult result)? onScan;
  void Function(ScannerStatus status, {String? message})? onStatus;

  Future<void> init();        // start this SDK, set up listeners
  Future<void> softTrigger(); // press-to-scan where supported; no-op otherwise
  Future<void> dispose();     // detach callbacks, release native resources
}
```

**Name-collision warning:** `scanwedge` exports its **own** `ScanResult` class. In
`scanwedge_scanner_service.dart`, import the package with a prefix
(`import 'package:scanwedge/scanwedge.dart' as sw;`) and map `sw.ScanResult` → our
`ScanResult`. Don't let the two clash.

---

## 6. Interface mapping — how each SDK fills the contract

### 6a. Honeywell — `honeywell_scanner 8.0.0`

Instantiable: one `HoneywellScanner()` per service instance.

| Contract       | Maps to |
|----------------|---------|
| `init()`       | emit `initialising` → `await isSupported()`; if false emit `deviceNotSupported` and stop → `setScannerDecodeCallback(...)` → `setScannerErrorCallback(...)` → optional `setProperties(...)` → `await startScanner()` → emit `ready` |
| `softTrigger()`| `await startScanning()` (software trigger = true) |
| `dispose()`    | `await disposeScanner()` (removes callback, stops scanner, releases channel) + set `onScan`/`onStatus` = null |
| symbology      | **Available** — decode callback delivers a `ScannedData` carrying the code + symbology id |
| device check   | **Yes** — `isSupported()` → drives `deviceNotSupported` |

Caveat: the native channel is shared across instances — always `disposeScanner()` before
creating another (matters when switching scanner type at runtime).

### 6b. Point Mobile — `pointmobile_scanner_advanced 0.0.15`

Static/singleton API (`PMScanner`, `PMUtils`). There is no per-instance object — the service
class is a thin wrapper over static calls, app-wide single scanner.

| Contract       | Maps to |
|----------------|---------|
| `init()`       | emit `initialising` → `await PMScanner.initScanner(resultType: ResultType.userMessage)` → `PMScanner.onDecode = (Symbology s, String code) => onScan(...)` → emit `ready` (wrap in try/catch → `error`) |
| `softTrigger()`| **No-op** — no public software-trigger / toggle in the API (roadmap only). Document as unsupported. |
| `dispose()`    | `PMScanner.onDecode = null` + detach `onScan`/`onStatus`. No native release method is exposed. |
| symbology      | **Available** — `onDecode` delivers a `Symbology` enum + barcode string (`s.name`) |
| device check   | **None** — no `isSupported()`. Can't emit `deviceNotSupported` reliably; treat init failure as `error`. |

Caveats: use `ResultType.userMessage` so `onDecode` fires. `ResultType.clipboardKeycodePaste`
needs `PMUtils.listenClipboard()` instead — don't mix. Static state means switching away and
back must re-`initScanner`.

### 6c. Scanwedge — `scanwedge 1.1.3`

| Contract       | Maps to |
|----------------|---------|
| `init()`       | emit `initialising` → `final p = await Scanwedge.initialize()` → `await p.isDeviceSupported()`; if false emit `deviceNotSupported` and stop → `await p.createProfile(ProfileModel(profileName: 'multiScanner', enabledBarcodes: [...], keepDefaults: true))` → subscribe `p.stream.listen((sw.ScanResult r) => onScan(...))` → emit `ready` |
| `softTrigger()`| `await p.toggleScanning()` (this is the SOFTTRIGGER) |
| `dispose()`    | `await _sub.cancel()` → `await p.disableScanner()` → detach callbacks |
| symbology      | **Available** — `sw.ScanResult` exposes the label/`hardwareBarcodeType` (verify exact field name in the 1.1.3 API ref before coding) |
| device check   | **Yes** — `isDeviceSupported()` / `supportedDevice` |

**Enum names — frozen at 1.1.3** (this is the version-drift the brief warns about; use these
exact spellings/casing):

- `SupportedDevice { zebra, honeywell, invalid }`
- `BarcodeTypes { aztec, codabar, code128, code39, code93, datamatrix, ean128, ean13, ean8, gs1DataBar, gs1DataBarExpanded, i2of5, mailmark, maxicode, pdf417, qrCode, upca, upce0, manual, unknown }`
- `AimTypes { trigger, timedHold, timedRelease, pressAndRelease, presentation, continuousRead, pressAndSustain, pressAndContinue, timedContinuous }`

Note `qrCode`, `upce0`, `gs1DataBar`, `i2of5` casing — these are the identifiers that move
between versions. Build `enabledBarcodes` from `BarcodeTypes.code128.create(...)` style calls.

---

## 7. ScannerStatus emission matrix

| Status               | Honeywell | Point Mobile | Scanwedge |
|----------------------|-----------|--------------|-----------|
| `idle`               | before `init()` (all) | before `init()` | before `init()` |
| `initialising`       | start of `init()` | start of `init()` | start of `init()` |
| `ready`              | after `startScanner()` | after `initScanner` + callback set | after profile + stream subscribed |
| `deviceNotSupported` | `isSupported()` == false | **n/a** (no check) | `isDeviceSupported()` == false |
| `error`              | error callback / exception | init exception | initialize/stream error |

---

## 8. Open items to resolve in Phase 1

1. Confirm scanwedge `sw.ScanResult`'s exact field names (`barcode`, label/`hardwareBarcodeType`)
   against the pinned 1.1.3 API reference — dartdoc was not machine-readable here.
2. Honeywell `.aar` + Point Mobile `.jar` native drop-ins (§3) before any on-device build.
3. Decide the default `enabledBarcodes` set for the scanwedge profile.
4. Point Mobile `softTrigger()` is a no-op — confirm the UI scan button is expected to be
   disabled/greyed for that scanner type.
```
