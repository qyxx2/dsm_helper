# Task 5 Batch 2 — Fixed Overview Core UI Acceptance

> Date: 2026-10-09  
> Repository: `qyxx2/dsm_helper`  
> Working branch: `feature/t5-dashboard`  
> Starting Batch 1 acceptance HEAD: `e54f28ce7fdd5c8a867b4d0e065bd0e2e7f3e31d`  
> **Validated Batch 2 implementation HEAD:** `5992469bf82543dca31566656aca3c1f9f1475d4`

## Scope and contract evidence

This acceptance covers **Task 5 Batch 2 only** in the approved [Task 5 Batch Plan](../plans/2026-10-09-task-5-dashboard-batch-plan.md), under the [Feature Design](../specs/2026-10-09-task-5-dashboard-feature-design.md), [Contract Matrix](../contracts/2026-10-09-task-5-dashboard-contract-matrix.md), Task 2 Visual Design and inherited Batch 1 data-state contracts.

- **`T5-DEVICE-01`:** `DeviceSummary` reads the supplied hostname and actual `System.upTime`, reusing existing uptime formatting. Missing identity values remain omitted. The normal layout places hostname on the left and uptime on the right; large-text presentation is exercised.
- **`T5-RESOURCE-01`:** `CoreResourceSection` uses available CPU utilization, actual model 1/5/15-minute load averages and `System.sysTemp` **labeled as system temperature**. It does not invent a 10-minute sample or CPU-temperature authority. Missing inputs do not generate a fabricated zero reading.
- **`T5-RESOURCE-02`:** Memory percentage uses `Utilization.memory.realUsage`. Unverified absolute-memory field units are deliberately **not** converted or labeled GiB; absent memory fields do not produce zeroes. An independent absolute-memory-unit verification is not claimed.
- **`T5-RESOURCE-03`:** Volume rows use real `Storage.volumes`, existing display-name/status semantics and byte-based used/total/free arithmetic only when capacity inputs are valid. Multiple volumes are rendered separately. No Task 5-specific utilization warning threshold is added.
- **Consumes `T5-STATE-01/02`, `T5-REFRESH-01/02`:** Standalone `OverviewPage` owns one `OverviewController`, loads initially, starts one auto-refresh owner, forwards changes in `SettingProvider.refreshDuration` as **seconds**, supports pull-to-refresh, retains last-valid values and displays source-local loading/error/stale text. It disposes the controller on unmount.

The standalone page uses the existing `InitDataProvider` for device hostname, the provided notification callback for its action, and Task 2 Material 3 colors/typography, compact surfaces and 6dp progress bars. No second DSM API or transport authority, legacy visual widget, widget-owned polling loop, database change or auth/session authority is introduced.

## RED → GREEN evidence

1. **Device/core-resource RED:** `9a296720ae7b86dfe1b28670b3a1eeabe370d7f2`, CI **#170** / [run 37885743806](https://github.com/qyxx2/dsm_helper/actions/runs/37885743806) — 139 pre-existing tests passed; the two new widget-test files failed to load specifically because the two production widgets did not yet exist.
2. **Device/core-resource GREEN:** production commit `895b09afbf848d747b4550232ac9a578180cdc83`; first CI **#171** found a test assertion that matched both “5 分钟” and “15 分钟” (146 passed, 1 failed). This assertion alone was disambiguated in `051db082732791bb254897ce390d421c4d77ab11`; CI **#172** / [run 37886108695](https://github.com/qyxx2/dsm_helper/actions/runs/37886108695) completed **success, 147 passed**, analyzer clean and APK built. No production-code modification was required for that test correction.
3. **OverviewPage RED:** `0e952aa287f2bb293a32328778ffe0400f6392f0` started the page tests. CI **#173** also found a test-only `Size` symbol collision with the storage model; `362c410eec506ecad4b74a73c0d89641c06f78bd` changed the test viewport reference to `ui.Size`. CI **#174** / [run 37887088847](https://github.com/qyxx2/dsm_helper/actions/runs/37887088847) then passed all 147 preceding tests and failed only on absent `overview_page.dart` / `OverviewControllerFactory`: valid missing-implementation RED.
4. **OverviewPage GREEN:** `5992469bf82543dca31566656aca3c1f9f1475d4` added the standalone page. CI **#175** / [run 37887234181](https://github.com/qyxx2/dsm_helper/actions/runs/37887234181) completed **success, 153 passed**, analyzer clean, and signed APK Artifact uploaded. The newly added page tests exercise initial loading, partial failure isolation, V1/refresh/stale/V2, manual pull refresh, runtime cadence change and disposal, notification callback, Light/Dark and 2.2× text scale.

These RED runs are recorded as expected failures, **not** successful validations. The final GREEN evidence is tied to one precise tested implementation SHA.

## Final CI proof — exact implementation HEAD

- Workflow: **Modern UI Android CI**.
- Run: **#175**, Run ID **`37887234181`**, Job ID **`113679862801`**.
- Checkout/implementation SHA: **`5992469bf82543dca31566656aca3c1f9f1475d4`**.
- Flutter: **3.22.3**.
- Whole-project **`flutter test`**: **153 tests passed, 0 failed**.
- **`flutter analyze lib/new_ui test/new_ui`**: **No issues found**.
- **`flutter build apk --debug --flavor beta`**: **success**; output `build/app/outputs/flutter-apk/app-beta-debug.apk`.
- Package ID: **`top.apaipai.dsm_helper`**.
- Stable development signing SHA-256: **`0b8e6e0765cfba89e156f3037b66c9e9382d91f788e5e9be50516df02313d9a2`**.
- APK Artifact: **`dsm-helper-modern-ui-android-debug`**, ID **`11596843182`**, size **190021881 bytes**.
- Artifact ZIP SHA-256: **`85a5bb8caf195186ce960346223c6c1ff0748dd73d917641a4a59fbd05870034`**.
- [CI proof](https://github.com/qyxx2/dsm_helper/actions/runs/37887234181) · [Artifact](https://github.com/qyxx2/dsm_helper/actions/runs/37887234181/artifacts/11596843182).

The Batch Plan's focused command groups (`flutter test test/new_ui/dashboard`, `flutter test test/new_ui/theme test/new_ui/system`, `flutter analyze lib/new_ui/dashboard test/new_ui/dashboard`) were **not separately invoked**. The successful CI instead performed an **inclusive full Flutter test run** and a **broader new-UI analysis** covering those test/code paths. No local Flutter/Dart runtime execution is claimed.

## Exact diff boundary

GitHub compare from Batch 2 start `e54f28ce7fdd5c8a867b4d0e065bd0e2e7f3e31d` to tested implementation SHA contains **exactly these six new files**:

1. `lib/new_ui/dashboard/overview_page.dart`
2. `lib/new_ui/dashboard/widgets/device_summary.dart`
3. `lib/new_ui/dashboard/widgets/core_resource_section.dart`
4. `test/new_ui/dashboard/overview_page_test.dart`
5. `test/new_ui/dashboard/device_summary_test.dart`
6. `test/new_ui/dashboard/core_resource_section_test.dart`

No changes to the legacy Dashboard, `DsmApi`, model/provider source, Task 3/4 shell, authentication, Android build setup, workflow, or unrelated Task files. This acceptance document is the **only** additional docs-only file.

## Exit Gate, limitations, and handoff

**Batch 2 automated Exit Gate: PASS**, supported by the exact final tested implementation commit: fixed core UI independently exists, sparse model fields are omitted instead of fabricated, stale/refresh status is explicit, large-font/Light/Dark widget tests passed, whole Flutter regression and analyzer passed, and Android build/package/signing/Artifact checks passed.

**Not manually accepted:** Real-device visual density, long-term physical Android timing, actual NAS/DSM metric display or upgrade installation on the phone. No real-device acceptance is claimed. This standalone Overview is **not** wired to the application shell; the formal Task 5 shell-cutover and end-to-end real-device Gate remain assigned to downstream Batch 7. The current installed dashboard remains legacy.

Per **`CI-DOCS-01`**, this docs-only acceptance commit does not require rebuilding an unchanged implementation. After the document is committed, the branch documentation HEAD differs from the **tested implementation SHA** above; this distinction is intentional.

**Stop after Task 5 Batch 2. Do not automatically start Batch 3, merge into `modern-ui`, or change another Task.**
