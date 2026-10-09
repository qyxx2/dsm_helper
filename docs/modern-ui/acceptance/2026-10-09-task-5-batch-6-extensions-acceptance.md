# Task 5 Batch 6 — CurrentConnection / TaskScheduler Modern Extensions Acceptance

> Date: 2026-10-09  
> Repository: `qyxx2/dsm_helper`  
> Branch: `feature/t5-dashboard`  
> Starting HEAD (Batch 5 acceptance): `3fd09031c2e16d1effa937a293ede42487cd130f`  
> **Final verified Batch 6 implementation HEAD:** `296e463cdd5324f3ed0afbd8fbf8a622e8c96904`  
> Gate: **PASS — automated Batch 6 scope only**.

## Contract authorities and implementation boundaries

Authoritative sources: [Task 5 Batch Execution Plan](../plans/2026-10-09-task-5-dashboard-batch-plan.md), [Task 5 Feature Design](../specs/2026-10-09-task-5-dashboard-feature-design.md), [Task 5 Contract Matrix](../contracts/2026-10-09-task-5-dashboard-contract-matrix.md), frozen Modern UI Visual Design, and the actual legacy `CurrentConnection.get()` / `TaskScheduler.list()` authorities.

- **T5-EXT-01 — CurrentConnection:** `OverviewDataSource.production()` reads only from `CurrentConnection.get()`. The source is loaded only while `SYNO.SDS.SystemInfoApp.ConnectionLogWidget` is enabled. Successful empty data is rendered as no current connections; refresh failure preserves last-valid data as stale. The Modern widget exposes compact real user/source fields only and no kick/disconnect mutation control.
- **T5-EXT-02 — TaskScheduler:** `OverviewDataSource.production()` reads only from `TaskScheduler.list()`. The source is loaded only while `SYNO.SDS.TaskScheduler.TaskSchedulerWidget` is enabled. Successful empty data is rendered as no scheduled tasks; refresh failure preserves last-valid data as stale. The Modern widget exposes task name, next trigger and enabled state only and no run/enable/delete/edit mutation control.
- **Refresh/lifecycle invariant:** both extensions participate in the existing `OverviewController.refresh()` / manual refresh / one periodic timer lifecycle. No second controller or timer was introduced. Enabling an owned extension joins the controller-owned refresh lifecycle; disabling resets its visible source state and prevents future loads. Per-extension generations prevent a delayed response from publishing after disable.
- **B5 configuration relationship:** Overview derives enabled extensions only from the authoritative DSM `moduleList`, filters to the two Task 5-owned IDs, preserves DSM order for presentation, and synchronizes selection into the existing controller. Deferred/core/opaque IDs remain non-extension entries and do not create phantom Modern summaries. The Batch 5 full-list merge/save path remains unchanged and its tests remain in the passing suite.
- **Scope boundary:** no legacy CurrentConnection/TaskScheduler mutation path was reused, no legacy Dashboard source was changed, no Task 6 work was started, and no Batch 7 shell cutover was performed.

## Ordered RED → GREEN evidence

1. **Steps 1–2 — controller/data-source extension lifecycle.** RED controller contract commit `5c1a94badcb7b08a9affb5fde2414235420b6381`; CI [#196](https://github.com/qyxx2/dsm_helper/actions/runs/37899618236), Run ID `37899618236`: **189 tests passed / 1 test file failed to load** because the required extension loader typedefs/constructor fields, controller getters and `updateEnabledExtensions` API did not yet exist. Minimal implementation `fface9cb78078227d4361ecd0b87b0848d6185bc` added the two production authorities, conditional requests, source states, generation guards and selection API while retaining the single existing refresh owner. CI [#197](https://github.com/qyxx2/dsm_helper/actions/runs/37900085899), Run ID `37900085899`, Job ID `113720341341`: **210 tests passed**, analyzer clean, signed APK built.
2. **Step 3 — CurrentConnection read-only widget contract.** RED test commit `7044f88dfe7c0689a558343faee083f9d2fd95c1`; CI [#198](https://github.com/qyxx2/dsm_helper/actions/runs/37901019963), Run ID `37901019963`: **210 tests passed / 1 failed**, solely because `current_connection_extension.dart` / `CurrentConnectionExtension` did not exist.
3. **Step 4 — TaskScheduler read-only widget contract.** RED test commit `6eda39d74e4a17ef147a6f2740c342ed363e6fb8`; CI [#199](https://github.com/qyxx2/dsm_helper/actions/runs/37901345531), Run ID `37901345531`: **210 tests passed / 2 failed**, solely because both planned extension widget implementations were absent. The new TaskScheduler fixture itself compiled far enough to expose only the expected missing widget implementation.
4. **Step 5 — two read-only widgets.** Implementation `7afb8c934b0a9e5c1927e8c5f8dd0c14c054b59a` made the Step 3/4 widget tests GREEN. CI [#200](https://github.com/qyxx2/dsm_helper/actions/runs/37901687477), Run ID `37901687477`: **218 tests passed**, then analyzer failed only on two unused `dart:async` imports in the new test files. Root cause was test-only import residue, not production behavior. Commit `b2753f478a7a134a1ec3bb8c1d820c9f83f84cb5` removed exactly those two imports. CI [#201](https://github.com/qyxx2/dsm_helper/actions/runs/37901935465), Run ID `37901935465`, Job ID `113726274110`: **218 tests passed**, analyzer clean, signed APK built.
5. **Step 6 — B5 configuration → polling → display relationship.** RED relationship test commit `b87c4d8992da442c91e131caf528818dea24a5d0`; CI [#202](https://github.com/qyxx2/dsm_helper/actions/runs/37903056657), Run ID `37903056657`: **218 tests passed / 1 failed**. The precise failure was `connectionCalls` expected `1` but actual `0` for an initially selected `ConnectionLogWidget`, proving the controller/widget existed but `moduleList` had not yet been wired into Overview selection. Commit `296e463cdd5324f3ed0afbd8fbf8a622e8c96904` added only the missing Overview synchronization/rendering path.
6. **Step 7 — final GREEN / full regression / analyzer / APK.** CI [#203](https://github.com/qyxx2/dsm_helper/actions/runs/37903369126), Run ID **`37903369126`**, Job ID **`113730875887`**, verified checkout **`296e463cdd5324f3ed0afbd8fbf8a622e8c96904`**, **completed / success**: **219 tests passed, 0 failed**, analyzer clean, Android beta debug APK built, package/signing identity verified, artifact uploaded.

The project workflow executed the **whole `flutter test` suite** and its configured new-UI analyzer targets on the final implementation HEAD. This covers the Batch 6 dashboard, session, legacy and app tests present in the repository. The Batch Plan's separately grouped focused commands were **not independently executed in a local Flutter SDK** because this execution environment has no Flutter/Dart installation; do not treat those command groups as separately witnessed runs.

## Final CI and APK identity

| Evidence | Verified result |
| --- | --- |
| Workflow | Modern UI Android CI |
| Final run / job | **#203 / `37903369126` / `113730875887`** |
| Immutable source SHA | `296e463cdd5324f3ed0afbd8fbf8a622e8c96904` |
| Run/job conclusion | **completed / success** |
| Whole-suite Flutter tests | **219 passed, 0 failed** |
| New UI analyzer | **No issues found** |
| Flutter beta debug APK | **Build successful** |
| APK output | `build/app/outputs/flutter-apk/app-beta-debug.apk` |
| Package ID | `top.apaipai.dsm_helper` |
| Signing certificate SHA-256 | `0b8e6e0765cfba89e156f3037b66c9e9382d91f788e5e9be50516df02313d9a2` |
| Uploaded artifact | `dsm-helper-modern-ui-android-debug` |
| Artifact ID | **`11603647454`** |
| Artifact size | `190021881` bytes |
| Uploaded artifact ZIP SHA-256 | `fee8cfb02c56f43659c91b2ede595fe136285e35e4c07426ffdd4aed623c89dc` |

[Downloadable GitHub Actions APK artifact #11603647454](https://github.com/qyxx2/dsm_helper/actions/runs/37903369126/artifacts/11603647454).

## Diff boundary and Exit Gate

GitHub Compare from starting HEAD `3fd09031c2e16d1effa937a293ede42487cd130f` to final verified implementation `296e463cdd5324f3ed0afbd8fbf8a622e8c96904` confirms **exactly these nine Batch-6-authorized production/test paths**:

1. `lib/new_ui/dashboard/overview_data_source.dart` — modified.
2. `lib/new_ui/dashboard/overview_controller.dart` — modified.
3. `lib/new_ui/dashboard/overview_page.dart` — modified.
4. `lib/new_ui/dashboard/widgets/current_connection_extension.dart` — added.
5. `lib/new_ui/dashboard/widgets/task_scheduler_extension.dart` — added.
6. `test/new_ui/dashboard/overview_controller_test.dart` — modified.
7. `test/new_ui/dashboard/current_connection_extension_test.dart` — added.
8. `test/new_ui/dashboard/task_scheduler_extension_test.dart` — added.
9. `test/new_ui/dashboard/overview_extension_relationship_test.dart` — added.

**Batch 6 Exit Gate: PASS (automated).**

- Selected Task 5-owned extension IDs control the corresponding real source loaders and visible summaries.
- Both extensions share the existing single controller/manual/auto-refresh lifecycle; overlap and delayed-disable cases are covered by controller tests, and no second timer/polling owner exists.
- CurrentConnection and TaskScheduler Modern surfaces are read-only; kick/run/enable/delete/edit capabilities remain outside the Modern Overview.
- The real B5 provider/config save result controls extension start/stop and display while core resource data remains visible.
- Deferred and opaque IDs survive the B5 save path and do not create phantom extension widgets.
- The existing Batch 5 preservation/configuration tests remain part of the fully passing 219-test suite.

**NOT TESTED / NOT CLAIMED:** live CurrentConnection/TaskScheduler reads against the user's DSM, physical-device extension rendering, APK overlay installation/data retention for this Batch, formal Modern Overview shell cutover, cold-start/context-switch behavior, or Task 5 overall completion. The authoritative Batch Plan assigns those integrated shell/device gates to **Batch 7**, not Batch 6.

Per `CI-DOCS-01`, this acceptance record is a docs-only commit; its subsequent branch HEAD does not replace immutable implementation SHA `296e463...` verified by CI #203 and does not require another Android CI run.

**Stop after Task 5 Batch 6.** Do not automatically start Batch 7, merge `feature/t5-dashboard` into `modern-ui`, or modify another Task.
