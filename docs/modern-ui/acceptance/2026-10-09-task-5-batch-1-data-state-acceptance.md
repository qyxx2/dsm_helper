# Task 5 Batch 1 — Overview Data / Refresh State Foundation Acceptance

> **Status: PASS — Batch 1 automated Exit Gate**
> Date: 2026-10-09
> Task: Task 5 — Dashboard
> Batch: 1 — Overview Data / Refresh State Foundation
> Branch: `feature/t5-dashboard`
> Batch start: `82912d8e21114f6070a020ea36fa8c6fc34a9e80`
> **Verified implementation HEAD: `5429aec4755a03419eba620fa7d21545e6db470e`**

## Implementation and frozen contracts

- **`T5-DATA-01` / `T5-DATA-02`:** The production adapter calls only the existing `System.info()`, `Utilization.get()`, `Storage.loadInfo()`, and `DsmNotify.notify()` model entry points. Each source publishes independently. A successful empty notification collection is valid; a null model is unavailable; a thrown exception is not silently converted into empty success. Tests individually fail each source while asserting the other three remain valid.
- **`T5-STATE-01` / `T5-STATE-02`:** `OverviewSourceState<T>` exposes the frozen `initial/loading/valid/refreshing/stale/error/unavailable` phases and source-local values, errors and freshness timestamp. A pending refresh retains prior valid V1, failure retains V1 and its timestamp as stale, and subsequent success replaces V1 with V2 and clears the failure. Storage/notification failures do not blank independently valid system/utilization values. Fast sources publish without waiting for a slow sibling.
- **`T5-REFRESH-01` / `T5-REFRESH-02`:** The `OverviewController` owns one periodic timer and one in-flight refresh cycle. A slow request does not start an overlapping cycle; changing the refresh interval replaces the timer, and stop/dispose cancels it. A manual refresh invokes the four source loaders without clearing last-valid data. The caller supplies the interval; connecting it to `SettingProvider.refreshDuration` and the pull gesture remains downstream UI integration, not this Batch.
- **`T5-AUTH-01`:** Concurrent `DsmException(119)` failures produce exactly one `onAuthInvalidated` signal per controller lifetime; subsequent 119 failures do not repeat it. Non-119 DSM failures and transport errors remain local and never signal auth invalidation. Connecting this emitted signal to the existing Task 4 same-account reauthentication navigation is downstream shell work; no second auth authority was created in Batch 1.
- **Supports `T5-CTX-01`:** After disposing controller A, a delayed A result produces no further A notifications and does not contaminate a newly initialized B controller. Stop/dispose also prevents future automatic ticks. Actual live shell context switch wiring is deferred to the Task 5 shell-cutover Batch.

No Overview widgets, legacy Dashboard changes, new request transport, global session authority, shell cutover, schema migration, or Task 5 Batch 2+ files are included.

## RED → GREEN and test evidence

1. **Source-state RED:** `7106dbc8be6e71bffaa16af9615a4995871f5eeb` — CI **#162** / `37874153525` completed failure specifically on the absent `overview_source_state.dart` source types. This is expected missing-implementation RED evidence, not proof of a working model.
2. **Source-state GREEN:** first code submission `c7e7f145da31463aea4c5af16ed438deaf91acad` inadvertently omitted the already added test file; the corrective `f81bc24987db9c6d8a3a7f285ab0660b0ab3cd79` restored it. The compare from the RED test commit to the corrected GREEN commit shows exactly the two new production files, retaining the RED tests. CI **#164** / `37874479972` completed success with both source-state tests and full regression.
3. **Controller RED:** `a994b296bb36af296c4e5c4d77cb538f13a6e1ce` — CI **#165** / `37874702188` completed failure because `overview_controller.dart` and its controller types did not yet exist. This is expected controller RED evidence.
4. **Controller GREEN:** `bf310dd101e379d1f35ad572f07cf4b2d2e153ef` introduced the controller; `7705bfce77ed6dc76773b755816596cc3cbc4617` normalized the refresh completion Future type. CI **#167** / `37874908918` completed success for the resulting controller/test HEAD.
5. **Relationship and strengthened invariants:** `7a2d2810f3a310f6078f878ae0ea2f37b2a89ddd` added disposal/context relationship tests, with CI **#168** / `37874951325` completed success. `5429aec4755a03419eba620fa7d21545e6db470e` strengthened per-source failures, in-flight V1 preservation, independent publication and mixed stale behavior; final CI **#169** completed success. The relationship tests were added after the implementation and have GREEN evidence; **no separate failing relationship RED run is claimed**.

The named Batch Plan focused commands were not run as separate invocations. The authoritative remote workflow instead ran a **complete `flutter test`** (including all `test/new_ui/dashboard`, `test/new_ui/session`, and `test/new_ui/startup` tests) and broader `flutter analyze lib/new_ui test/new_ui`. These are inclusive validations rather than claims of separately executed focused commands. Flutter/Dart executables were not available in the assistant runtime; no local Flutter execution is claimed.

## Final CI proof — exact implementation HEAD

- Workflow: **Modern UI Android CI**
- Run: **#169** — Run ID **`37876824233`**, Job ID **`113647222115`**
- Checkout / implementation SHA: **`5429aec4755a03419eba620fa7d21545e6db470e`**
- Final conclusion: **`completed / success`**
- Flutter version: **3.22.3**
- Complete **`flutter test`**: **139 tests passed, 0 failed**
- **`flutter analyze lib/new_ui test/new_ui`**: **No issues found**
- **`flutter build apk --debug --flavor beta`**: **success**
- APK path: `build/app/outputs/flutter-apk/app-beta-debug.apk`
- Package: **`top.apaipai.dsm_helper`**
- Fixed development signing certificate SHA-256: **`0b8e6e0765cfba89e156f3037b66c9e9382d91f788e5e9be50516df02313d9a2`**
- APK identity check and Artifact upload: **success**
- Artifact name: `dsm-helper-modern-ui-android-debug`
- Artifact ID: `11592558719`
- Artifact ZIP SHA-256: `043669f6dd6d0d828dcb18a23ce0741330b01bbd9abd0d3b81dde98fb342a7c2`
- Workflow: https://github.com/qyxx2/dsm_helper/actions/runs/37876824233
- Artifact: https://github.com/qyxx2/dsm_helper/actions/runs/37876824233/artifacts/11592558719

## Diff boundary

GitHub compare from Batch 1 start `82912d8e21114f6070a020ea36fa8c6fc34a9e80` to the final validated implementation commit contains **exactly six new files**, all inside the frozen Batch 1 allowance:

1. `lib/new_ui/dashboard/overview_source_state.dart`
2. `lib/new_ui/dashboard/overview_data_source.dart`
3. `lib/new_ui/dashboard/overview_controller.dart`
4. `test/new_ui/dashboard/overview_source_state_test.dart`
5. `test/new_ui/dashboard/overview_controller_test.dart`
6. `test/new_ui/dashboard/overview_refresh_relationship_test.dart`

No legacy, shell, UI, Android config, dependency or unrelated production file changed.

## Gate, limitations and handoff

**Batch 1 automated Exit Gate: PASS.** Four-source independence, last-valid/stale behavior, one refresh/timer authority, one-shot 119 signaling, disposal isolation, session/startup regression, analysis, APK build and stable signing were covered by CI #169 at the exact accepted implementation SHA.

**Real Android/DSM behavior has not been manually validated**, and is not claimed. This Batch introduces a standalone data/controller layer and does not wire a user-accessible Dashboard yet. Physical-device end-to-end verification belongs to later Task 5 UI/shell acceptance.

This acceptance is a **documentation-only commit**. Per `CI-DOCS-01`, no duplicate APK build is required; the implementation SHA above remains the tested code even after the acceptance commit advances this branch.

**Stop at Task 5 Batch 1. Do not automatically begin Batch 2, merge `feature/t5-dashboard` to `modern-ui`, or begin another Task.**
